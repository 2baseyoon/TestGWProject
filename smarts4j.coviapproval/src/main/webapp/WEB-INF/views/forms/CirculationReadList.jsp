<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<script>

	var ListGrid = new coviGrid();
	
	var FormInstID = ${FormInstID};
	var BStored = Boolean(${BStored}); // 20210126 이관문서 추가

	var sessionObj = null; //전체호출
	
	$(document).ready(function () {	
		sessionObj = Common.getSession(); //전체호출
		setGrid();		
	});
		
	function setGrid(){
		setGridHeader();
		setGridConfig();
		setListData();
	}
	
	function setGridHeader(){

		 var headerData =[{key:'Kind', label:"<spring:message code='Cache.lbl_apv_gubun'/>", width:'10',align:'center',formatter:function(){
							var sKind = ""
								switch(this.item.Kind){
								case "C":
									sKind = "<spring:message code='Cache.lbl_apv_Circulate'/>"; //회람
									break;
								case "1":
									sKind = "<spring:message code='Cache.lbl_apv_CReference'/>"; //사전참조
									break;
								case "0":
									sKind = "<spring:message code='Cache.lbl_apv_cc'/>"; //참조
									break;
								
								}
								return sKind;
						}},
						{key:'SenderName', label:"<spring:message code='Cache.lbl_approval_circulator'/>", width:'10', align:'center', 
							formatter:function(){
								// 2022-11-11 플라워 네임 적용
								if (typeof (setUserFlowerName) == 'function') {
									return setUserFlowerName(this.item.SenderID, CFN_GetDicInfo(this.item.SenderName), 'AXGrid');
								} else {
									return CFN_GetDicInfo(this.item.SenderName);
								}
							} 
						},						
						{key:'ReceiptDate', label:"<spring:message code='Cache.lbl_apv_senddate'/>",  width:'15', align:'center', formatter: function(){
							return CFN_TransLocalTime(this.item.ReceiptDate,_StandardServerDateFormat);
						}},
						{key:'UserName', label:"<spring:message code='Cache.lbl_apv_circulation_person'/>/<spring:message code='Cache.lbl_apv_circulation_dept'/>",  width:'16', align:'center', formatter:function(){
							if(this.item.DeptName ==undefined || this.item.DeptName == "") {
					    		// 2022-11-11 플라워 네임 적용
								if (typeof (setUserFlowerName) == 'function' && this.item.ReceiptType == 'P') {
									return setUserFlowerName(this.item.UserCode, CFN_GetDicInfo(this.item.ReceiptName), 'AXGrid');
								} else {
									return CFN_GetDicInfo(this.item.ReceiptName);
								}
					    	  }
					    	  else {
					    		// 2022-11-11 플라워 네임 적용
								if (typeof (setUserFlowerName) == 'function' && this.item.ReceiptType == 'P') {
									return "("+CFN_GetDicInfo(this.item.DeptName)+")"+" "+setUserFlowerName(this.item.UserCode, CFN_GetDicInfo(this.item.UserName), 'AXGrid');
								} else {
									return "("+CFN_GetDicInfo(this.item.DeptName)+")"+" "+CFN_GetDicInfo(this.item.UserName);
								}
					    	  }
						}},
						{key:'ReadDate', label:"<spring:message code='Cache.lbl_approval_confirmDate'/>",  width:'15', align:'center', formatter: function(){
							return CFN_TransLocalTime(this.item.ReadDate,_StandardServerDateFormat);
						}},
						{key:'Comment', label:"<spring:message code='Cache.lbl_apv_comment'/>",  width:'26', align:'center', formatter: function(){
							return "<span style='white-space: pre-wrap;' title='"+this.item.Comment+"'>"+this.item.Comment+"</span>";
						}},
						{key:'DataState', label:"<spring:message code='Cache.lbl_apv_delete'/>",  width:'8', align:'center', 
							formatter:function(){
								//[기안자에게 해당하는 회람], [이미 읽은 회람], [기안자 이외의 현재 로그인한 사용자의 회람] 삭제 불가능
								if(sessionObj["UR_Code"] != this.item.SenderID
										|| sessionObj["UR_Code"] == this.item.UserCode 
										|| (typeof this.item.ReadDate != 'undefined' && this.item.ReadDate.length > 0)){
									return "";
								} else {
									return '<button type="button" class="AXButton" onclick="del_Click(\''+ this.item.CirculationBoxID +'\');"><spring:message code='Cache.lbl_apv_delete'/></button>';
								}
							}
						}];
		 ListGrid.setGridHeader(headerData);	
	}

	
	function del_Click(CirculationBoxID){
		Common.Confirm("<spring:message code='Cache.msg_apv_093' />", "Confirmation Dialog", function (result) {
	         if (result) {
		$.ajax({
			url:"deleteCirculationReadListData.do",
			type:"post",
			data:{
				CirculationBoxID:CirculationBoxID,
				"ModID":sessionObj["USERID"],
				BStored : BStored
				},
			async:false,
			success:function(data) {
				ListGrid.removeList([{CirculationBoxID:CirculationBoxID}]);
			},
			error:function(response, status, error){
				CFN_ErrorAjax("deleteCirculationReadListData.do", response, status, error);
			}
			});
        }
     });
	}
	
	
	function setGridConfig(){
		var configObj = {
				targetID : "ListGrid",
				height:"346",
				listCountMSG:"<b>{listCount}</b> 개",
                page: {
                	display: false,
					paging: false
                },
                body:{
                	onclick:function(){
                		if(this.c == 1)
                			openFormDraft(this.list[this.index].FormID);
                	}
                }
		}
		
		ListGrid.setGridConfig(configObj);
	}
	
	function setListData(){					
		
		ListGrid.bindGrid({
			ajaxUrl: "getCirculationReadListData.do",//조회 컨트롤러
			ajaxPars: {FormIstID : FormInstID, BStored : BStored},
			onLoad: function(){
			}
		});
	} 
	function btnClose_Click(){
		Common.Close();
	}

</script>
<form>
<div class="layer_divpop ui-draggable" id="testpopup_p" style="width:100%; min-width:840px; z-index: 51;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
  <div class="divpop_contents">
    <div class="pop_header" id="testpopup_ph">
      <h4 class="divpop_header ui-draggable-handle" id="testpopup_Title"><span class="divpop_header_ico"><spring:message code='Cache.btn_apv_CCorCirculation_View'/></span></h4>
      <!--<a class="divpop_close" id="testpopup_px" style="cursor: pointer;"></a><a class="divpop_window" id="testpopup_LayertoWindow" style="cursor: pointer;" onclick="Common.LayerToWindow('layerpopuptest.do?as=ads', 'testpopup', '331px', '270px', 'both')"></a><a class="divpop_full" style="cursor: pointer;" onclick="Common.ScreenFull('testpopup', $(this))"></a><a class="divpop_mini" style="cursor: pointer;" onclick="Common.ScreenMini('testpopup', $(this))"></a>-->
    </div>
    <!-- 팝업 Contents 시작 -->
    <div class="popBox">
    	<div class="coviGrid">
	<div id="ListGrid"></div>
	</div>
	<div>
	
      <div class="popBtn"> <a class="owBtn" href="#ax" onclick="btnClose_Click();" return false;><spring:message code='Cache.btn_apv_close'/></a>
</div>
</div>
</div>
</div>
</div>
</form>