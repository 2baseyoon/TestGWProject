<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<div class="layer_divpop ui-draggable boradPopLayer " id="testpopup_p" style="width:499px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="popContent layerType02 boardReadingList ">
				<div>				
					<div class="top">			
						<p><spring:message code='Cache.lbl_total'/> 0<spring:message code='Cache.lbl_CountMan'/></p>
					</div>
					<div class="middle">
						<div class="tblList tblCont">					
							<div id="historyGrid"></div>			
						</div>
					</div>
					<div class="bottom">
						
					</div>
				</div>
			</div>
		</div>	
	</div>
<script>

	var historyGrid = new coviGrid();
	var messageID_pop = CFN_GetQueryString("messageID");
	
	$(document).ready(function () {	
		setGrid();		
	});
		
	function setGrid(){
		setGridHeader();
		setGridConfig();
		setListData();
		$(".AXgridStatus").remove();
	}
	
	function setGridHeader(){
		var headerData =[{key:'rowNum', label:'<spring:message code="Cache.lbl_Num"/>', width:'2', align:'center', sort: false,
				formatter:function(){ 
					return formatRowNum(this); 
				}
			},			//번호
			{key:'HistoryType', label:'<spring:message code="Cache.lbl_ProcessingHistory"/>',  width:'4', align:'center'},		//처리 이력
			{key:'Comment', label:'<spring:message code="Cache.lbl_ReasonForProcessing"/>',  width:'4', align:'center'},		//처리 사유
			{key:'DisplayName', label:'<spring:message code="Cache.lbl_Register"/>',  width:'7', align:'center'},			//등록자 이름
			{key:'DeptName', label:'<spring:message code="Cache.lbl_dept"/>',  width:'7', align:'center'},					//등록자 부서
			{key:'RegistDate', label:'<spring:message code="Cache.lbl_RegistDateHour"/>' + Common.getSession("UR_TimeZoneDisplay"), width:'6',align:'center', formatter: function(){
				return CFN_TransLocalTime(this.item.RegistDate);
			}}			//조회일시
		];
		historyGrid.setGridHeader(headerData);	
	}
	
	function setGridConfig(){
		var configObj = {
			targetID : "historyGrid",
			height:"auto",
			listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
			page : {
				pageNo:1,
				pageSize:10
			},
			paging : true,
			colHead:{}
		}
		
		historyGrid.setGridConfig(configObj);
	}
	
	function setListData(){
		historyGrid.bindGrid({
			ajaxUrl: "/groupware/admin/selectMessageHistoryGridList.do",
			ajaxPars: {messageID : messageID_pop},
		});
	} 

	function formatRowNum(pObj){
		return pObj.index+1;
	}
	
	//하단의 닫기 버튼 함수
	function btnClose_Click(){
		Common.Close();
	}

</script>
