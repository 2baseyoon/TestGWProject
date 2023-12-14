<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<h3 class="con_tit_box">
	<span class="con_tit"><spring:message code="Cache.lbl_ExtDatasourceMng"/></span><%-- DB pool 설정 --%>
</h3>
<form id="form1">
	<div style="width:100%;min-height: 500px">
		<div id="topitembar01" class="topbar_grid">
			<input type="button" class="AXButton BtnRefresh" value="<spring:message code="Cache.lbl_Refresh"/>" onclick="Refresh();"/>
			<input type="button" class="AXButton BtnAdd"  value="<spring:message code="Cache.btn_Add"/>" onclick="addDatasource(false);"/>
			<input type="button" class="AXButton BtnDelete"  value="<spring:message code="Cache.btn_delete"/>" onclick="deleteDatasource();"/>
			<input type="button" class="AXButton" value="Reload Pool" onclick="reloadPool();"/>
		</div>
		<div id="mygrid"></div>
	</div>
</form>

<script type="text/javascript">
	var datasourceGrid;
	var headerData;

	initContent();
	
	function initContent(){ 
		datasourceGrid = new coviGrid();
		// 헤더 설정
		
		headerData =[
		             {key:'chk', label:'chk', width:'25', align:'center', formatter:'checkbox'},
		             {key:'DatasourceSeq', label:'Datasource Seq', width:'70', align:'center', display:false},
            		 {key:'ConnectionPoolName',  label:'Pool Name', width:'70', align:'center',
		            	 formatter:function () {
		            		 	return "<a href='#' onclick='updateDatasource(false, \""+ this.item.DatasourceSeq +"\"); return false;'>"+this.item.ConnectionPoolName+"</a>";
		            		 }},
		             {key:'Description', label:'<spring:message code="Cache.lbl_Description"/>', sort:false, width:'300', align:'center'},
		             {key:'SortSeq', label:'<spring:message code="Cache.lbl_Sort"/>',  width:'30', align:'center'},
		             {key:'ModifyDate', label:'<spring:message code="Cache.lbl_ModifyDate"/>' + Common.getSession("UR_TimeZoneDisplay"), width:'100', align:'center', sort:"desc", 
				          formatter: function(){
			      			return CFN_TransLocalTime(this.item.ModifyDate);
			      		  }, dataType:'DateTime'
			      	  }
			      	];
		setGrid();			// 그리드 세팅
		searchGrid();
	}
	//그리드 세팅
	function setGrid(){
		datasourceGrid.setGridHeader(headerData);
		
		datasourceGrid.setGridConfig({
			targetID : "mygrid",
			height:"auto"
		});
	}
	
	// baseconfig 검색
	function searchGrid(){
		
		datasourceGrid.page.pageNo = 1;
		datasourceGrid.bindGrid({
 			ajaxUrl:"/covicore/extdatabase/getDatasourceList.do",
 			ajaxPars: {
 			}
		});
	}
	
	// 추가 버튼에 대한 레이어 팝업
	function addDatasource(pModal){
		parent.Common.open("","adddatasource","Add Datasource","/covicore/extdatabase/goExtDatasourcePopup.do?mode=add","700px","550px","iframe",pModal,null,null,true);
	}
	
	// 그리드 안의 설정키 클릭 했을 때 수정 레이어 팝업
	function updateDatasource(pModal, datasourceSeq){
		parent.Common.open("","updatedatasource","Modify Datasource","/covicore/extdatabase/goExtDatasourcePopup.do?mode=modify&datasourceSeq="+datasourceSeq,"700px","550px","iframe",pModal,null,null,true);
	}
	
	// 삭제
	function deleteDatasource(){
		var deleteobj = datasourceGrid.getCheckedList(0);
		if(deleteobj.length == 0){
			Common.Warning("<spring:message code='Cache.msg_Common_03'/>");
			return;
		}else{
			var deleteSeq = "";
			for(var i=0; i<deleteobj.length; i++){
				if(i==0){
					deleteSeq = deleteobj[i].DatasourceSeq;
				}else{
					deleteSeq = deleteSeq + "," + deleteobj[i].DatasourceSeq;
				}
			}
			
			Common.Confirm('<spring:message code="Cache.msg_ReallyDelete"/>', "Confirm", function (result) {
				if(result) {
					$.ajax({
						type:"POST",
						data:{
							"DeleteData" : deleteSeq
						},
						url:"/covicore/extdatabase/delDatasource.do",
						success:function (data) {
							if(data.result == "ok")
								Common.Inform("<spring:message code='Cache.msg_138'/>");
							datasourceGrid.reloadList();
						},
						error:function(response, status, error){
							CFN_ErrorAjax("/covicore/extdatabase/delDatasource.do", response, status, error);
						}
					});
					
				}
			});
		}
	}
	
	// 새로고침
	function Refresh(){
		searchGrid();
	}
	
	//선택 또는 전체 대상 reload
	function reloadPool(){
		var chkobj = datasourceGrid.getCheckedList(0);
		var DatasourceSeq = "";
		if(chkobj.length == 0){
			// Common.Warning("<spring:message code='Cache.msg_Common_03'/>");
		}else{
			var DatasourceSeq = "";
			for(var i=0; i<chkobj.length; i++){
				if(i==0){
					DatasourceSeq = chkobj[i].DatasourceSeq;
				}else{
					DatasourceSeq = deleteSeq + "," + chkobj[i].DatasourceSeq;
				}
			}
		}
		if("" == DatasourceSeq){
			if(!confirm("선택된 행이 없습니다. 전체 대상으로 새로 등록합니다.")){
				return;
			}
		}
		$.ajax({
			type:"POST",
			url:"/covicore/extdatabase/refreshDBPool.do",
			data : {
				DatasourceSeqStr : DatasourceSeq
			},
			success:function (data) {
				if(data.status=='SUCCESS'){
	    			Common.Inform("<spring:message code='Cache.msg_apv_alert_006'/>"); // 성공적으로 처리 되었습니다.
	    		}else{
	    			Common.Warning("<spring:message code='Cache.msg_apv_030'/>");//오류가 발생헸습니다.
	    		}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/covicore/extdatabase/refreshDBPool.do", response, status, error);
			}
		});
	}
	
</script>