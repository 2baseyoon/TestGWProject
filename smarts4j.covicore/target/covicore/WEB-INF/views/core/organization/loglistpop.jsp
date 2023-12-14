<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'> 
	<meta http-equiv='expires' content='0'> 
	<meta http-equiv='pragma' content='no-cache'>
	<jsp:include page="/WEB-INF/views/cmmn/include.jsp"></jsp:include>
	<style>
		/* div padding */
		.divpop_body {
			padding: 20px !important;
		}
	</style>
</head>
<body>
	<form>
	<div class="AXTabs">
		<div style="width:100%;" id="divLogList">
			<div style="width: 100%; margin-top: 10px;">
				<div id="topitembar_1" class="topbar_grid">
					&nbsp;&nbsp;타입별 검색&nbsp;&nbsp;
					<select id="SyncType" class="AXSelect" style="width:100px" onchange="changeLogList(this.value,'','','');">
							<option value="">전체</option>
							<option value="INSERT">추가</option>
							<option value="UPDATE">수정</option>
							<option value="DELETE">삭제</option>
					</select>
				
					&nbsp;&nbsp;사용여부&nbsp;&nbsp;
					<select id="IsUse" class="AXSelect" style="width:100px" onchange="changeLogList('',this.value,'','');">
							<option value="">전체</option>
							<option value="Y">Y</option>
							<option value="N">N</option>
					</select> 
					
					&nbsp;&nbsp;동기화 상태&nbsp;&nbsp;
					<select id="SyncStatus" class="AXSelect" style="width:100px" onchange="changeLogList('','',this.value,'');">
							<option value="">전체</option>
							<option value="Y">성공</option>
							<option value="N">실패</option>
					</select>
					
					&nbsp;&nbsp;코드별 검색&nbsp;&nbsp;
					<input type="text" class="AXInput" id="txtObjectCode" onkeypress="if(event.keyCode=='13') searchLog();">
					<input type="button" class="AXButton" value="검색" onclick="searchLog();" id="btn_searchLog">
				</div>	
				
				<!-- Grid - GroupLog -->
				<div id="resultBoxWrap">
					<div id="orgLogListGrid"></div>
				</div>
			</div>
		</div>
	</div>
	</form>
	<script type="text/javascript">				
		var _strObjectType = "${ObjectType}";
		var _strSyncType = "${SyncType}";
		var _strSyncMasterID = "${SyncMasterID}";		
		var _strInsertDate = "${InsertDate}";				

		var orgLogListGrid = new coviGrid();
		
		$(document).ready(function(){				
			$("#SyncType").val(_strSyncType);			
			switch(_strObjectType)
			{
				case "GR" :
					setGroupLogGrid();	
					break;
				case "UR" :
					setUserLogGrid();
					break;
				case "AddJob":
					setAddJobLogGrid();
					break;
			}
					
			setGridConfig();			
			bindLogGridData(_strObjectType,_strInsertDate,_strSyncType,_strSyncMasterID);
		});
		
		//Grid 관련 사항 추가 -
		//Grid 생성 관련
		function setGroupLogGrid(){
			orgLogListGrid.setGridHeader([
								  {key:'Seq', label:'Seq', width:'30', align:'center', formatter : function(){
									  return "<span name='code'>" + this.item.Seq + "</span>";
								  }},
								  {key:'SyncType', label:'SyncType', width:'40', align:'center', formatter : function(){
									  return "<span name='code'>" + this.item.SyncType + "</span>";
								  }},
								  {key:'GroupCode', label:'GroupCode', width:'70', align:'center', formatter : function(){
									  return "<span name='code'>" + this.item.GroupCode + "</span>";
								  }},
								  {key:'CompanyCode', label:'CompanyCode', width:'70', align:'center', formatter : function(){
									  return "<span name='code'>" + this.item.CompanyCode + "</span>";
								  }},
								  {key:'DisplayName', label:'DisplayName', width:'70', align:'center', formatter : function(){
									  return "<span name='code'>" + this.item.DisplayName + "</span>";
								  }},
								  {key:'IsUse', label:'IsUse', width:'30', align:'center', formatter : function(){
									  return "<span name='code'>" + this.item.IsUse + "</span>";
								  }},
								  {key:'SyncStatus', label:'SyncStatus', width:'30', align:'center', formatter : function(){
									  return "<span name='code'>" + this.item.SyncStatus + "</span>";
								  }},
								  {key:'InsertDate', label:'InsertDate', width:'100', align:'center', formatter : function(){
									  return "<span name='code'>" + this.item.InsertDate + "</span>";
								  }}
					      		]);
		}
		
		function setUserLogGrid(){
			orgLogListGrid.setGridHeader([
								  {key:'Seq', label:'Seq', width:'30', align:'center', formatter : function(){
									  return "<span name='code'>" + this.item.Seq + "</span>";
								  }}, //사용자
								  {key:'SyncType', label:'SyncType', width:'40', align:'center', formatter : function(){
									  return "<span name='code'>" + this.item.SyncType + "</span>";
								  }},
								  {key:'UserCode', label:'UserCode', width:'70', align:'center', formatter : function(){
									  return "<span name='code'>" + this.item.UserCode + "</span>";
								  }},
								  {key:'CompanyCode', label:'CompanyCode', width:'70', align:'center', formatter : function(){
									  return "<span name='code'>" + this.item.CompanyCode + "</span>";
								  }},
								  {key:'DisplayName', label:'DisplayName', width:'70', align:'center', formatter : function(){
									  return "<span name='code'>" + this.item.DisplayName + "</span>";
								  }},
								  {key:'IsUse', label:'IsUse', width:'30', align:'center', formatter : function(){
									  return "<span name='code'>" + this.item.IsUse + "</span>";
								  }},
								  {key:'SyncStatus', label:'SyncStatus', width:'30', align:'center', formatter : function(){
									  return "<span name='code'>" + this.item.SyncStatus + "</span>";
								  }},
								  {key:'InsertDate', label:'InsertDate', width:'100', align:'center', formatter : function(){
									  return "<span name='code'>" + this.item.InsertDate + "</span>";
								  }}
					      		]);
		}
		
		function setAddJobLogGrid(){
			orgLogListGrid.setGridHeader([
								  {key:'Seq', label:'Seq', width:'30', align:'center', formatter : function(){
									  return "<span name='code'>" + this.item.Seq + "</span>";
								  }}, //사용자
								  {key:'SyncType', label:'SyncType', width:'40', align:'center', formatter : function(){
									  return "<span name='code'>" + this.item.SyncType + "</span>";
								  }},
								  {key:'UserCode', label:'UserCode', width:'70', align:'center', formatter : function(){
									  return "<span name='code'>" + this.item.UserCode + "</span>";
								  }},
								  {key:'CompanyCode', label:'CompanyCode', width:'70', align:'center', formatter : function(){
									  return "<span name='code'>" + this.item.CompanyCode + "</span>";
								  }},
								  {key:'DeptCode', label:'DeptCode', width:'70', align:'center', formatter : function(){
									  return "<span name='code'>" + this.item.DeptCode + "</span>";
								  }},
								  {key:'IsUse', label:'IsUse', width:'30', align:'center', formatter : function(){
									  return "<span name='code'>" + this.item.IsUse + "</span>";
								  }},
								  {key:'SyncStatus', label:'SyncStatus', width:'30', align:'center', formatter : function(){
									  return "<span name='code'>" + this.item.SyncStatus + "</span>";
								  }},
								  {key:'InsertDate', label:'InsertDate', width:'100', align:'center', formatter : function(){
									  return "<span name='code'>" + this.item.InsertDate + "</span>";
								  }}
					      		]);
		}

		//Grid 설정 관련
		function setGridConfig(){
			var configObj = {
				targetID : "orgLogListGrid",		// grid target 지정
				height:"auto",
				page : {
					pageNo:1,
					pageSize:10
				},
				paging : true
			};
			
			// Grid Config 적용
			orgLogListGrid.setGridConfig(configObj);
		}	

		function bindLogGridData(pStrObjectType,pStrInsertDate,pStrSyncType,pStrSyncMasterID,pStrIsUse,pStrSyncStatus,pStrObjectCode) {			
			orgLogListGrid.bindGrid({	
				ajaxUrl:"/covicore/admin/orgmanage/getLogList.do",
				ajaxPars: {
					ObjectType: pStrObjectType,
					InsertDate: pStrInsertDate,
					SyncType: pStrSyncType,
					SyncMasterID: pStrSyncMasterID,					
					IsUse: pStrIsUse,
					SyncStatus: pStrSyncStatus,
					ObjectCode: pStrObjectCode,
					sortBy: orgLogListGrid.getSortParam('one').queryToObject()
				}
			});				
		}	
		
		function searchLog()
		{
			changeLogList('','','',$("#txtObjectCode").val());  
		}
		
		function changeLogList(pStrSyncType, pStrIsUse, pStrSyncStatus, pStrObjectCode) {		
			var strSyncType = pStrSyncType;
			var strIsUse = pStrIsUse;
			var strSyncStatus = pStrSyncStatus;
			var strObjectCode = pStrObjectCode;						
			
			if(pStrSyncType == '')
			{
				strSyncType = $("#SyncType option:selected").val();
			}
		
			if(pStrIsUse == '')
			{
				strIsUse = $("#IsUse option:selected").val();
			}
			
			if(pStrSyncStatus == '')
			{
				strSyncStatus = $("#SyncStatus option:selected").val();
			}
			
			if(pStrObjectCode == '')
			{
				strObjectCode = $("#txtObjectCode").val();
			}
			
			bindLogGridData(_strObjectType, _strInsertDate, strSyncType,_strSyncMasterID, strIsUse, strSyncStatus, strObjectCode);			
		}
	</script>
</body>