<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<div class="sadmin_pop">
	<div class="tblList tblCont">
		<div id="gridDiv"></div>
	</div>
	<div class="popBottom">
		<input id="btnClose" type="button" value="<spring:message code='Cache.btn_Close'/>" class="AXButton"> <!-- 닫기 -->
	</div>
</div>

<script>
var listPopup = {
		grid: new coviGrid(),
		initContent:function(){
			$("#btnClose").off("click").on("click", function(){
				Common.Close();
			});
			
			var headerData = [
				{key: 'DomainName', label:'<spring:message code="Cache.lbl_DN_Code"/>', width: '80', align: 'left'}, // 도메인 코드
	             {key:'ReadDate', label:'<spring:message code="Cache.lbl_ViewDate"/>' + Common.getSession("UR_TimeZoneDisplay"), width:'80', align:'center', 
      				formatter: function(){
      					return CFN_TransLocalTime(this.item.ReadDate);
  					}},
			     {key:'RegisterName', label:'<spring:message code="Cache.lbl_Register"/>',  width:'50', align:'center'},
	             {key:'RegistDate', label:'<spring:message code="Cache.lbl_RegistDate"/>' + Common.getSession("UR_TimeZoneDisplay"), width:'80', align:'center', 
      				formatter: function(){
      					return CFN_TransLocalTime(this.item.RegistDate);
  					}},
			];
			
			this.grid.setGridHeader(headerData);
			this.grid.setGridConfig({
				targetID		: "gridDiv",
				height:"auto"
			});
			
			this.bindGrid();
		},
		bindGrid : function(){
			this.grid.page.pageNo = 1;
			this.grid.bindGrid({
	 			ajaxUrl:"/groupware/board/manage/getNoticeHistoryList.do",
	 			ajaxPars: {"messageID" : CFN_GetQueryString("messageID")}
			});
		},
}
$(document).ready(function (){
	listPopup.initContent();
});

		

</script>