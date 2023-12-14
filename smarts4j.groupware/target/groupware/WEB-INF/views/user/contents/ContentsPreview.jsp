<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"
	import="egovframework.baseframework.util.SessionHelper,egovframework.baseframework.util.PropertiesUtil, egovframework.baseframework.util.SessionHelper,egovframework.coviframework.util.RedisDataUtil"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
<% 
	String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path"); 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<style>
.AXbindDateExpandBox .timeDisplayBox{padding-top:0px}
.AXCalendar .timeBox {display: block;}
.AXCalendar .timeBox .minuteSlider {top:57px}
.AXCalendar .timeBox .timeDisplay {top : 93px}
.AXCalendar .timeBox .AMPM {top : 93px}
</style>
<!-- 컨텐츠앱 추가 -->
<div class="cRContBottom mScrollVH " style="top:0px;">.
	<div class="boardAllCont">
		<div class="allMakeView">
			<div class="boradTopCont allMakeSettingView active">
				<div class="inputBoxContent">
					<div id="divUserDefField" class="makeMoreInput  active">
					</div>
				</div>
			</div>	
		</div>
		<div id=divDate>
	        <span class="dateTip">
	        	<spring:message code='Cache.msg_notPrevImg'/>
	        </span>
	     </div>
	</div>	
</div>	
<script>
var bizSection= "Board";
var folderID;
var messageID;
var version;

(function(param){

	var setInit = function(){
		g_boardConfig = {"IsContents": "Y"};
		var fieldList = [];
		$(opener.document).find(".component_wrap .component").each(function (i,v){
			var pushData = opener.form_data[$(v).data("cid")];
			if (pushData["FieldType"] == "Image"){
				pushData["FieldType"] = "Label";
				pushData["FieldWidth"] = ""
				pushData["FieldName"] = "<spring:message code='Cache.msg_notPrevImg'/>";
			}else{
				pushData["FieldName"] = CFN_GetDicInfo(pushData["FieldName"],"ko");
			}	
			fieldList.push(pushData);
		});
		board.renderUserDefFieldWrite(fieldList);
	};

	var init = function(){
		setInit();
	};
	
	init();
})({
	folderID: "${folderID}"
});
	
	</script>
