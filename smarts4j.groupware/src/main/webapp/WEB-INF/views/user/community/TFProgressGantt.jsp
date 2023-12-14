<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<script type="text/javascript" src="/groupware/resources/script/user/tf.js<%=resourceVersion%>"></script>
<div class="cRConTop titType">
	<h2 class="title"><spring:message code='Cache.lbl_ProgressReport'/></h2>						
</div>
<div class="cRContBottom mScrollVH ">
	<div id="ITMSubCont" id="divGantt" style="height:auto;min-height: 680px;">
		<iframe id="WbsIframe" style="width:100%;border:none;height:auto;min-height:680px;" src="">
		</iframe>
	</div>												
</div>
<!-- 툴팁 -->
<div id="divLangSelect" style="background-color:white;"></div>

<input type="hidden" id="hiddenMenuID" value=""/>
<input type="hidden" id="hiddenCU_ID" value=""/>
<input type="hidden" id="hiddenAT_ID" value=""/>
<input type="hidden" id="hiddenComment" value="" />
 <!-- ==== 히든필드 시작 ===== -->
<input type="hidden"  id="hidYear"   value="" />
<input type="hidden"  id="hidMonth"  value="" />
<input type="hidden"  id="hidGubun"  Value="D" />
<input type="hidden" id="txtProjectCode" />
 <!-- ==== 히든필드 종료 ===== -->
<script>
	//# sourceURL=TFProgress.jsp
	var communityId = typeof(cID) == 'undefined' ? 0 : cID;	// 커뮤니티ID
	var activeKey = typeof(mActiveKey) == 'undefined' ? 1 : mActiveKey;	// 커뮤니티 메뉴 Key
	
	//개별호출-일괄호출
	var sessionObj = Common.getSession(); //전체호출
	
	var lang = sessionObj["lang"];
	var userID = sessionObj["USERID"];
	//project code setting
	$("#txtProjectCode").val(communityId);
	//ready
	init();
	
	function init(){
		var iURL = "/groupware/biztask/goProjectGanttView.do";
		$("#WbsIframe").attr("src", iURL);		
	}	
	
	// 제목 클릭 
	function ViewAT(ActivityId) {
		Common.open("","ActivitySet","<spring:message code='Cache.btn_view' />","/groupware/tf/goActivityView.do?mode=VIEW&CLSYS=TF&CLMD=user&CLBIZ=TF&CSMU=T&C="+communityId+"&ActivityId="+ActivityId ,"950px", "650px","iframe", true,null,null,true);
	}    
</script>			