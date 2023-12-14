<%@ page language="java" contentType="text/html; charset=UTF-8"  pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

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
		
		label {
			font-size: 13px;
		}
		
		.colHeadTable, .gridBodyTable {
			font-size: 13px;
		}
	</style>
</head>

<form id="form1">
	<div style="width:100%;min-height: 500px">
		<div id="topitembar01" class="topbar_grid">
			<label>
				<input type="button" value="<spring:message code="Cache.btn_Refresh"/>" onclick="Refresh();" class="AXButton BtnRefresh"/>
				<input type="button" value="<spring:message code="Cache.btn_delete"/>" onclick="Delete();" class="AXButton BtnDelete"/>
			</label>
		</div>
		<div id="topitembar02"  class="topbar_grid">
			<label>
				▣ MasterID : ${msgID}&nbsp;
			</label>
			<label>
				▣ <spring:message code="Cache.lbl_Gubun"/>&nbsp;<!-- 구분 -->
				<select id="selMediaType" class="AXSelect" onchange="searchMsgList();"></select>
			</label>
		</div>
		<div id="msgGrid"></div>
	</div>
</form>
<script type="text/javascript">
//처리 성공 여부 ( N-미처리, I-진행중, R-재처리, F-실패, C-성공 )
	var myGrid;
	var headerData;
	var msgID = "${msgID}";
	
	//개별호출 일괄처리
	Common.getBaseCodeList(["NotificationMedia"]);
	
	window.onload = initContent();
	
	function initContent(){
				
		headerData = [{key:'chk', label:'chk', width:'20', align:'center', formatter: 'checkbox'},
		              {key:'SubSeq', label:'<spring:message code="Cache.lbl_Number"/>', width:'20', align:'center', formatter : function(){
						  return this.item.SubSeq.replace(".0", "");
					  }},
		              {key:'MediaType',  label:'<spring:message code="Cache.lbl_AlarmMedia"/>', width:'60', align:'center'}, /* 알림매체 */
	                  {key:'DisplayName',  label:'<spring:message code="Cache.lbl_receiver"/>', width:'80', align:'left', formatter : function(){
						  return this.item.DisplayName + "(" + this.item.GroupName + ")";
					  }}, /* 수신자 */
					  {key:'RetryCount', label:'<spring:message code="Cache.lbl_NoOfShipping"/>', width:'60', align:'center'},
	                  {key:'SendDate', label:'<spring:message code="Cache.lbl_SendDateTime"/>' + Common.getSession("UR_TimeZoneDisplay"), width:'80', align:'center', 
						formatter: function(){
							return CFN_TransLocalTime(this.item.SendDate);
						}
					  }, /* 발송일시 */
	                  {key:'SuccessState', label:'<spring:message code="Cache.lbl_ProcessStatus"/>', width:'50', align:'center', formatter : function(){
	                	  var sReturn = Common.getDic("SuccessState_" + this.item.SuccessState);							                	  
	                	  if(this.item.RetryCount != null && this.item.RetryCount != '' && this.item.RetryCount != '0')
						  		sReturn += "(" + this.item.RetryCount + ")";
	                	  return sReturn;
					  }}, /* 처리상태 */
	                  {key:'ResultMessage', label:'<spring:message code="Cache.lbl_result"/>', width:'80', align:'center'} /* 결과 */
	                  ];
		myGrid = new coviGrid();
		
		setGrid();
		
		//select box 바인딩
		setSelMediaType();
		
		setTimeout(function(){searchMsgList();}, 10);
	};

	function setGrid(){
		myGrid.setGridHeader(headerData);
		setGridConfig();
	}
	
	function setGridConfig(){
		var configObj = {
			targetID : "msgGrid",
			height: "auto", //"490px",
			sort : false,		// 정렬
			page : {
				pageNo:1,
				pageSize:10
			},
			paging : true
		};
		
		myGrid.setGridConfig(configObj);
	}
	
	function searchMsgList(){		
		var mediaType = $("#selMediaType").val();
		
		myGrid.page.pageNo = 1;
        
		myGrid.bindGrid({
 			ajaxUrl:"/covicore/admin/messaging/getmessagingsubdata.do",
 			ajaxPars: {
 				MessagingID: msgID,
 				MediaType: mediaType
 			},
 			onLoad:function(){
 				//custom 페이징 추가
 				$('.AXgridPageBody').append('<div id="custom_navi" style="text-align:center;margin-top:2px;"></div>');
			    myGrid.fnMakeNavi("myGrid");
 			}
		});
	}
	
	function Refresh(){
		location.reload();
	}
		
	function Delete(){
		var deleteObject = myGrid.getCheckedList(0);
		if(deleteObject.length == 0 || deleteObject == null){
			Common.Inform("<spring:message code='Cache.msg_selectTargetDelete'/>"); //삭제할 대상을 선택하세요.
			return false;
		}else{
			Common.Confirm("<spring:message code='Cache.msg_152'/>", "Confirmation Dialog", function (result) {
				if(result) {
					var deleteSeq = "";
					
					for(var i=0; i < deleteObject.length; i++){
						if(i==0){
							deleteSeq = deleteObject[i].SubID;
						}else{
							deleteSeq = deleteSeq + ";" + deleteObject[i].SubID;
						}
					}
					
					$.ajax({
						type:"POST",
						data:{
							"MessagingID" : msgID,
							"SubID" : deleteSeq
						},
						url:"/covicore/admin/messaging/deletemessagingdata.do",
						success:function (data) {
							if(data.status == "FAIL") {
								Common.Warning(data.message);
							} else {
								Common.Inform("<spring:message code='Cache.msg_ProcessOk'/>", "Information Dialog", function(result) {
									if(result) {
										parent.myGrid.reloadList();
										window.location.reload();
									}
								});
							}
						},
						error:function(response, status, error){
							CFN_ErrorAjax("/covicore/admin/messaging/deletemessagingdata.do", response, status, error);
						}
					});
				}
			});
		}
	}
	
	function setSelMediaType(){
		$('#selMediaType').append($('<option>', {
		        value: '',
		        text : "<spring:message code='Cache.lbl_all'/>" 
		 }));
		var objTodomsgType = coviCmn.codeMap["NotificationMedia"];
		$(objTodomsgType).each(function(idx, obj) {
			if (obj.Code == 'NotificationMedia')
				return true;
			$('#selMediaType').append($('<option>', { 
			        value: obj.Code,
			        text : obj.CodeName
			 }));
		});
	}
	
</script>
