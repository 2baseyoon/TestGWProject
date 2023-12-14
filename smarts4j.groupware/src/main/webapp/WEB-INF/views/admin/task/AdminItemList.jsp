<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<h3 class="con_tit_box">
	<span id="userName"  class="con_tit"></span>	
</h3>
<form>
	<!--탭 영역-->
	<div class="AXTabs">
		<div id="divTabTray" class="AXTabsTray" style="height:30px"> 
			<a id="folderTab"onclick="clickTab(this);" class="AXTab on" value="divFolder">폴더</a> <!-- 부서 -->
			<a id="taskTab" onclick="clickTab(this);" class="AXTab" value="divTask">업무</a> <!-- 사용자 -->
		</div>
	</div>
	
	<!--폴더 영역-->
	<div id="divFolder" style="margin-top: 5px; padding-top: 5px; width:100%;">
    	<div id="topitembar01" class="topbar_grid">
			<input id="refresh" type="button" class="AXButton BtnRefresh" value="새로고침" onclick="search('folder');"/><!--새로고침-->
		</div>	
		<div id="topitembar02" class="topbar_grid">
			<select id="folderStateSelect" class="AXSelect W80" onchange="search('folder')"></select>		 	
			<select id="folderSearchType" class="AXSelect W80" >
				<option value="Subject">폴더명</option>
				<option value="RegisterName">등록자</option>
			</select>		 	
			<input type="text" id="folderSearchWord" onkeypress="if (event.keyCode==13){ search('folder'); return false;}" class="AXInput" />
			<input type="button" value="검색" onclick="search('folder');" class="AXButton"/>
		</div>	
		<div id="folderGrid"></div>
	</div>
	
	<!--업무 영역-->
	<div id="divTask"  style="margin-top: 5px; padding-top: 5px; width:100%; display:none;">
    	<div id="topitembar01" class="topbar_grid">
			<input id="refresh" type="button" class="AXButton BtnRefresh" value="새로고침" onclick="search('task');"/><!--새로고침-->
		</div>	
		<div id="topitembar02" class="topbar_grid">
			<select id="taskStateSelect" class="AXSelect W80" onchange="search('task')"></select>		 	
			<select id="taskSearchType" class="AXSelect W80">
				<option value="Subject">업무명</option>
				<option value="RegisterName">등록자</option>
			</select>		 	
			<input  type="text" id="taskSearchWord" onkeypress="if (event.keyCode==13){ search('task'); return false;}" class="AXInput" />
			<input type="button" value="검색" onclick="search('task');" class="AXButton"/>
		</div>	
		<div id="taskGrid"></div>
	</div>
</form>


<script>
	var folderID = CFN_GetQueryString("folderID") == "undefined" ? '' : CFN_GetQueryString("folderID");
	var listGrid;

	init();
	
	function init(){
		if($("#hidOwnerCode").val() == '' || folderID == ''){
			$("#userName").text("사용자 및 폴더를 선택해주세요");
		}else{
			$("#userName").text($("#ownerName").val()+"님의 업무함" );
		}
		
		setControl();
		setGrid('folder');
	}
	
	// 탭 선택
	function clickTab(pObj){
		$("#divTabTray .AXTab").attr("class","AXTab");
		$(pObj).addClass("AXTab on");
		
		var objID = $(pObj).attr("value");
		
		$("#divFolder").hide();
		$("#divTask").hide();
		
		$("#" + objID).show();
        
        tabType = objID.replace("div", "").toLowerCase();
        
        setGrid(tabType);
	}
	
	function setControl(){
		var lang = Common.getSession("lang");
		coviCtrl.renderAjaxSelect(nitInfos = [ {
		    target : 'taskStateSelect',	
		    codeGroup : 'TaskState',
		    defaultVal : '',
		    width : '160',	
		    onclick : 'searchFolder'
		}], '', lang);
		
		coviCtrl.renderAjaxSelect(nitInfos = [ {
		    target : 'folderStateSelect',	
		    codeGroup : 'FolderState',
		    defaultVal : '',
		    width : '160',	
		    onclick : 'searchTask'
		}], '', lang);
		
	}
	//그리드 세팅
	function setGrid(gridType){
		listGrid = new coviGrid();
		
		if(gridType == 'folder'){
			// 헤더 설정
			listGrid.setGridHeader([	            
			    	                  {key:'FolderID', label:'ID', width:'5', align:'center'},
			    	                  {key:'DisplayName',  label:'폴더명', width:'35', align:'left', formatter:function(){
			    	                		  return "<a href='javascript:void(0);' onclick='goFolderSetPopup(\""+this.item.FolderID+"\")'>" + this.item.DisplayName + "</a>";
			    	                	  }
			    	                  },	
			    	                  {key:'FolderState',  label:'상태', width:'15', align:'center'},
			    	                  {key:'RegisterName',  label:'등록자', width:'25', align:'center' },
			    	                  {key:'RegistDate', label:'등록일' + Common.getSession("UR_TimeZoneDisplay"), width:'20', align:'center', sort:"asc", formatter: function(){
			    	  						return CFN_TransLocalTime(this.item.RegistDate);
			    	  				  }}
			    		      		]);
		}else if(gridType == 'task'){
			listGrid.setGridHeader([	            
			    	                  {key:'TaskID', label:'ID', width:'5', align:'center'},
			    	                  {key:'Subject',  label:'업무명', width:'25', align:'left', formatter:function(){
			    	                		  return "<a href='javascript:void(0);' onclick='goTaskSetPopup(\""+this.item.TaskID+"\")'>" + this.item.Subject + "</a>";
			    	                	  }
			    	                  },	     /*포탈명칭*/
			    	                  {key:'TaskState',  label:'상태', width:'10', align:'center'},	     /*포탈명칭*/
			    	                  {key:'StartDate',  label:'시작일', width:'15', align:'center' },
			    	                  {key:'EndDate', label:'종료일', width:'15', align:'center'},
			    	                  {key:'IsDelay', label:'지연여부', width:'10', align:'center'},
			    	                  {key:'RegisterName',  label:'등록자', width:'15', align:'center' },
			    	                  {key:'RegistDate', label:'등록일' + Common.getSession("UR_TimeZoneDisplay"), width:'15', align:'center', sort: 'asc', formatter: function(){
			    	  						return CFN_TransLocalTime(this.item.RegistDate);
			    	  				  }}
			    		      		]);
		}
		
		
		setGridConfig(gridType);
		search(gridType);				
	}
	
	// 그리드 Config 설정
	function setGridConfig(gridType){
		var configObj = {
			targetID : gridType+"Grid",
			height:"auto",
		};
		
		listGrid.setGridConfig(configObj);
	}
	

	//그리드 바인딩
	function search(gridType){		
		if(gridType == 'folder'){
			listGrid.bindGrid({
					ajaxUrl:"/groupware/task/getUserFolderList.do",
					ajaxPars: {
						"folderID": folderID,
						"userID" : $("#hidOwnerCode").val(),
						"stateCode" : $("#folderStateSelect").val(),
						"searchType" : $("#folderSearchType").val(),
						"searchWord" : $("#folderSearchWord").val(),
					}
			});
		}else if(gridType=='task'){
			listGrid.bindGrid({
				ajaxUrl:"/groupware/task/getUserTaskList.do",
				ajaxPars: {
					"folderID": folderID,
					"userID" : $("#hidOwnerCode").val(),
					"stateCode" : $("#taskStateSelect").val(),
					"searchType" : $("#taskSearchType").val(),
					"searchWord" : $("#taskSearchWord").val(),
				}
			});
		}
	}	
	
	//폴더 수정/조회 팝업 
	function goFolderSetPopup(targetFolderID){
		Common.open("","folderSet","폴더 관리","/groupware/task/goFolderSetPopup.do?mode=Modify&parentFolderID="+folderID+"&isOwner=N&folderID="+targetFolderID+"&isSearch=N","535px", "400px" ,"iframe", true,null,null,true);
	}

	//업무 수정/조회 팝업 
	function goTaskSetPopup(targetTaskID){
		Common.open("","taskSet","업무 추가","/groupware/task/goTaskSetPopup.do?mode=Modify&isOwner=N&taskID="+targetTaskID+"&folderID="+folderID+"&isSearch=N","990px", "570px" ,"iframe", true,null,null,true);
	}
	
	//사용자 함수를 쓰기 위해 필요없는 함수 추가
 	function getFolderItemList(){
 		
 	}
	
</script>