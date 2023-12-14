<%@page import="egovframework.baseframework.util.SessionHelper,egovframework.covision.groupware.util.BoardUtils,egovframework.covision.groupware.auth.BoardAuth,egovframework.baseframework.data.CoviMap,egovframework.coviframework.util.DicHelper,egovframework.coviframework.util.XSSUtils,egovframework.coviframework.logging.LoggerHelper"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%
String bizSection = request.getParameter("bizSection") == null ? "Board" : request.getParameter("bizSection");
String boardType  = request.getParameter("boardType") == null ? "Normal" : request.getParameter("boardType");	//Normal외에 메뉴별 타입

CoviMap params = new CoviMap();
BoardUtils.setRequestParam(request, params);	//parameter 자동 할당
params.put("bizSection", bizSection);

CoviMap configMap = new CoviMap();
CoviMap msgMap = new CoviMap();
CoviMap aclMap = new CoviMap();
if (request.getParameter("folderID")== null ){
	LoggerHelper.authErrorLogger((String) request.getAttribute("javax.servlet.forward.request_uri"), "NOAUTH", "", "", "Unauthorized : No Permission", "page");
	out.println("<script language='javascript'>window.location.href = '/covicore/coviException.do?CLSYS=portal&CLMD=user&CLBIZ=Portal&exceptionType=NoAuth';</script>");
	return;
}
else{
	String folderID = request.getParameter("folderID");			//í´ë ID
	CoviMap returnMap = BoardUtils.getFolderConfig(params);
	
	configMap = (CoviMap)returnMap.get("configMap");
	msgMap = (CoviMap)returnMap.get("msgMap");
	aclMap = (CoviMap)returnMap.get("aclMap");
	
	if (!returnMap.getBoolean("isAuth").equals(true) || !returnMap.getBoolean("isRead").equals(true)){
		LoggerHelper.authErrorLogger((String) request.getAttribute("javax.servlet.forward.request_uri"), "NOAUTH", "", "", "Unauthorized : No Permission", "page");
		out.println("<script language='javascript'>window.location.href = '/covicore/coviException.do?CLSYS=portal&CLMD=user&CLBIZ=Portal&exceptionType=NoAuth';</script>");
		return;
	}
	
	boolean hasModifyAuth = BoardAuth.getModifyAuth(params);
	out.println("<script language='javascript'>var hasModifyAuth = " + hasModifyAuth + ";</script>");
}
%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<div class="layer_divpop ui-draggable boradPopLayer" id="testpopup_p" style="width:930px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
<!-- 			<div class="pop_header" id="testpopup_ph"> -->
<!-- 				<h4 class="divpop_header ui-draggable-handle" id="testpopup_Title"><span class="divpop_header_ico">댓글 조회</span></h4><a class="divpop_close" id="testpopup_px" style="cursor: pointer;"></a> -->
<!-- 			</div> -->
			<div class="popContent commentLayerPop">
				<div class="">	
					<div id="divComment" class="top">
					</div>			
				</div>
			</div>
		</div>	
	</div>
	<input type="hidden" id="chkPop" value="Y"/>
<script>
	var bizSection = CFN_GetQueryString("bizSection");
	var messageID = CFN_GetQueryString("messageID");
	var version = CFN_GetQueryString("version");
	var folderType = CFN_GetQueryString("folderType");
	var commentDelAuth = "<%=BoardUtils.isCommentDelAuth(configMap)%>";
	
	$(document).ready(function () {
		coviComment.load('divComment', bizSection, messageID+"_"+version, null, folderType);
	});
	
	window['divComment' + '_callMapCallBack'] = function(data, elemID){
		//이미지 append 영역 생성
		if(!$('#' + elemID + ' .fileUpview.main').length){
			$('<ul class="clearFloat fileUpview main"></ul>').insertAfter('#' + elemID + ' .commInput.main .txtArearBox');
		}
		
		$('#' + elemID + ' .fileUpview.main').append(coviComment.makeMapRow(data, elemID, 'mapFileInfos'));
		
		Common.close(elemID + "_CoviCommentMap");
	};
</script>
