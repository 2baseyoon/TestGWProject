<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<script type="text/javascript">

	var lang = Common.getSession("lang");
	var resourceGrid = new coviGrid();

	$(document).ready(function (){
		$(".con_tit").text($(".admin-menu-active").text());
		setGrid();			// 그리드 세팅			
	});
	
	//그리드 세팅
	function setGrid(){
		resourceGrid.setGridHeader([	            
			{key:'chk', label:'chk', width:'3', align:'center', formatter: 'checkbox'},
			{key:'FolderID',  label:'ID', width:'4', align:'center'},	   /*ID*/
			{key:'DomainName',  label:'<spring:message code="Cache.lbl_OwnedCompany"/>', width:'7', align:'center',		/*소유회사 */
				formatter: function(){
					return CFN_GetDicInfo(this.item.DomainName,lang);
			}},     
			{key:'ResourceName',  label:'<spring:message code="Cache.lbl_Res_Name"/>', width:'26', align:'center',			  /*자원명*/
				formatter:function(){
					return CFN_GetDicInfo(this.item.ResourceName,lang);
			}},   
			{key:'FolderPath', label:'<spring:message code="Cache.lbl_Res_Div"/>', width:'31', align:'center'},     			   /*자원분류*/
			{key:'SortKey', label:'<spring:message code="Cache.lbl_PriorityOrder"/>', width:'7', align:'center', sort:"asc"},     			   /*우선순위*/
			{key:'RegisterName',  label:'<spring:message code="Cache.lbl_Register"/>', width:'7', align:'center',     /*등록자*/
				formatter:function(){
					return CFN_GetDicInfo(this.item.RegisterName,lang);
			}}, 
			{key:'RegistDate', label:'<spring:message code="Cache.lbl_RegistrationDate"/>' + Common.getSession("UR_TimeZoneDisplay"), width:'15', align:'center', 
				formatter: function(){
					return CFN_TransLocalTime(this.item.RegistDate);
			}}          /*등록일자*/ 
		]);
		setGridConfig();
		searchConfig();				
	}
	
	// 그리드 Config 설정
	function setGridConfig(){
		var configObj = {
			targetID : "resourceGrid",
			height:"auto",
			page : {
				pageNo:1,
				pageSize:10
			},
		};
		
		resourceGrid.setGridConfig(configObj);
	}

	//그리드 바인딩
	function searchConfig(){		
		var domainID = $("#leftDomainSelectBox").val();
		
		resourceGrid.bindGrid({
			ajaxUrl:"/groupware/resource/getMainResourceList.do",
			ajaxPars: {
				"domainID":domainID
			}
		});
	}	
	
	// 새로고침
	function gridRefresh(){
		resourceGrid.reloadList();
	}
	
	function modifyMainResource(){
		//자원 선택 | 메인화면 목록에 표시할 자원을 선택합니다.
		Common.open("","selectResource","<spring:message code='Cache.lbl_ResourceMainManage_01'/>","/groupware/resource/goResourceTreePopup.do?domainId="+$("#leftDomainSelectBox").val(),"350px","400px","iframe",true,null,null,true);
	}

	// 위로 버튼 클릭시 실행되며, 해당 항목을 위로 이동합니다.
    function upRow() {
        var checkedList = resourceGrid.getCheckedListWithIndex(0);
		
        if(checkedList.length <= 0){
            Common.Warning("<spring:message code='Cache.msg_Common_09'/>", "Warning Dialog", function () { });      // 이동할 항목을 선택하여 주십시오.
            return;
        }

        var oPreview = null;
        var oNow = null;

	    $.each(checkedList, function(idx, obj){
            // 현재 행: 위에서부터 선택 되어 있는 행 찾기
            // oNow = aObjectTR.filter(":eq(" + i.toString() + ")"); obj로 대체
			oNow = obj.item;
            
            // 이전 행 찾기: 현재 행 기준 위에서 선택 안되어 있는 행 찾기
            oPreview = null;
            for (var j = obj.index - 1; j >= 0; j--) {
                if (resourceGrid.list[j].FolderID == undefined) {
                    break;
                }
                if (resourceGrid.list[j].___checked[0] == true) {
                    continue;
                }
                oPreview = resourceGrid.list[j];
                break;
            }
            
            if (oPreview == null) {
            	 return true; //continue;
            }

            $.ajax({
            	url: "/groupware/resource/changeResourceSortKey.do",
            	type:"POST",
            	data:{
            		"folderID1": oPreview.FolderID,
            		"sortKey1": oPreview.SortKey,
            		"folderID2": oNow.FolderID,
            		"sortKey2": oNow.SortKey
            	},
            	success:function(data){
            		if(data.status =='SUCCESS'){
						resourceGrid.reloadList();
            		}else{
            			Common.Warning("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
            		}
            		
            	},
            	error:function(response, status, error){
            	     CFN_ErrorAjax("/groupware/resource/changeResourceSortKey.do", response, status, error);
            	}
            });
            
	    });
    }

    // 아래로 버튼 클릭시 실행되며, 해당 항목을 아래로 이동합니다.
    function downRow() {
    	var checkedList = resourceGrid.getCheckedListWithIndex(0);
  		
        if(checkedList.length <= 0){
            Common.Warning("<spring:message code='Cache.msg_Common_09'/>", "Warning Dialog", function () { });      // 이동할 항목을 선택하여 주십시오.
            return;
        }
        
        var oNext = null;
        var oNow = null;

        $.each(checkedList, function(idx, obj){
            // 현재 행: 아래에서부터 선택되어 있는 행 찾기
			oNow = obj.item;
            
            // 다음 행 찾기: 현재 행 기준 아래에서 선택 안되어 있는 행 찾기
            oNext = null;
            for (var j = obj.index + 1; j < resourceGrid.list.length; j++) {
                if (resourceGrid.list[j].FolderID == undefined) {
                    break;
                }
                if (resourceGrid.list[j].___checked[0] == true) {
                    continue;
                }
                oNext = resourceGrid.list[j];
                break;
            }
            
            if (oNext == null) {
            	 return true; //continue;
            }
            
            $.ajax({
            	url: "/groupware/resource/changeResourceSortKey.do",
            	type:"POST",
            	data:{
            		"folderID1": oNext.FolderID,
            		"sortKey1": oNext.SortKey,
            		"folderID2": oNow.FolderID,
            		"sortKey2": oNow.SortKey
            	},
            	success:function(data){
            		if(data.status=='SUCCESS'){
						resourceGrid.reloadList();
            		}else{
            			Common.Warning("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
            		}
            		
            	},
            	error:function(response, status, error){
            	     CFN_ErrorAjax("/groupware/resource/changeResourceSortKey.do", response, status, error);
            	}
            });
        });
    }
</script>

<h3 class="con_tit_box">
	<span class="con_tit"><spring:message code='Cache.CN_140'/></span>	<!--메인 화면 목록 관리-->
</h3>
<form id="form1">
    <div style="width:100%;min-height: 500px">
    	<div id="topitembar01" class="topbar_grid">
			<input id="refresh" type="button" class="AXButton BtnRefresh" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="gridRefresh();"/><!--새로고침-->
			<input id="modify" type="button" class="AXButton"  value="<spring:message code="Cache.lbl_change"/>" onclick="modifyMainResource();"/><!--변경-->
			<input id="up" type="button" class="AXButton BtnUp"  value="<spring:message code="Cache.lbl_Up"/>" onclick="upRow()"/><!--위로-->
			<input id="down" type="button" class="AXButton BtnDown"  value="<spring:message code="Cache.btn_Down"/>" onclick="downRow()"/><!--아래로-->
		</div>	
		<div id="resourceGrid"></div>
	</div>
</form>