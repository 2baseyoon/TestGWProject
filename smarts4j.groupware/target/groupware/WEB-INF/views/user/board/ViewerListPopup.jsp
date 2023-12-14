<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<div class="layer_divpop ui-draggable boradPopLayer " style="width:100%;" id="testpopup_p"source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="popContent layerType02 boardReadingList ">
				<div>				
					<div class="top">			
						<p><spring:message code='Cache.lbl_total'/> 0<spring:message code='Cache.lbl_CountMan'/></p>
					</div>
					<div class="middle">
						<div class="tblList tblCont">					
							<div id="viewerGrid"></div>			
						</div>
					</div>
					<div class="bottom">
						
					</div>
				</div>
			</div>
		</div>	
	</div>
<script>

	var viewerGrid = new coviGrid();
	var messageID_pop = CFN_GetQueryString("messageID");
	var messageVer_pop = CFN_GetQueryString("messageVer");
	var folderID_pop = CFN_GetQueryString("folderID");
	var bizSection_pop = CFN_GetQueryString("CLBIZ");
	
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
		var headerData =[{key:'rowNum', label:"<spring:message code='Cache.lbl_Num'/>", width:'2',align:'center',
							formatter:function(){ 
								return formatRowNum(this); 
							}
						},			//번호
						{key:'DisplayName', label:"<spring:message code='Cache.lbl_Viewer'/>",  width:'5', align:'center', addClass:'bodyTdFile',		//조회자
							formatter:function(){
								return '<div id="btnFlower" class="btnFlowerName" onclick="coviCtrl.setFlowerName(this)" style="position:relative;cursor:pointer" data-user-code="'+ this.item.ReaderCode +'" data-user-mail="" >' + this.item.DisplayName +'</div>';
							}	
						},			
						{key:'JobPositionName', label:"<spring:message code='Cache.lbl_JobLevel'/>",  width:'5', align:'center'},	//직급
						{key:'DeptName', label:"<spring:message code='Cache.lbl_dept'/>",  width:'7', align:'center'},				//부서
						{key:'ReadDate', label:"<spring:message code='Cache.lbl_ViewDate'/>" + Common.getSession("UR_TimeZoneDisplay"), width:'9',align:'center', sort:'desc', formatter: function(){
							return CFN_TransLocalTime(this.item.ReadDate);
						}},//조회일시
						{key:'Version', label:"Ver",  width:'3', align:'center'}
		];
		viewerGrid.setGridHeader(headerData);	
	}
	
	function setGridConfig(){
		var configObj = {
			targetID : "viewerGrid",
			height:"auto",
			listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>", 
			page : {
				pageNo:1,
				pageSize:10
			},
			paging : true,
			colHead:{}
		}
		
		viewerGrid.setGridConfig(configObj);
	}
	
	function setListData(){
		viewerGrid.bindGrid({
			ajaxUrl: "/groupware/admin/selectMessageViewerGridList.do",
			ajaxPars: {messageID : messageID_pop, version:messageVer_pop, folderID : folderID_pop, bizSection: bizSection_pop},
			onLoad:function(){
				$(".top p").text("<spring:message code='Cache.lbl_total'/> " + viewerGrid.page.listCount + "<spring:message code='Cache.lbl_CountMan'/>");
			},
			onError:function(res){
				Common.Warning(Common.getDic('msg_apv_030'));//오류가 발생헸습니다.
			}
		});
	} 

	function formatRowNum(pObj){
		return ((viewerGrid.page.pageNo -1) * viewerGrid.page.pageSize ) + pObj.index+1;
	}
	
	//하단의 닫기 버튼 함수
	function btnClose_Click(){
		Common.Close();
	}

</script>
