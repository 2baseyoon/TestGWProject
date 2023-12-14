<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%  String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer(); %>
<script type="text/javascript" src="/approval/resources/script/user/ApprovalListCommon.js<%=resourceVersion%>"></script>

<div class="cRConTop titType">
	<h2 class="title"><spring:message code='Cache.lbl_approval_writeApv'/></h2><!-- 결재작성 -->
</div>
<div class="cRContBottom mScrollVH ">
	<div class="apprvalContent">
		<div class="apprvalBottomCont">
			<!-- 본문 시작 -->
			<div class="content_in">
				<div class="bodyMenu">
					<div class="btn_group mb10">
						<div class="selBox" style="width:61px;" >
							<span class="selTit" ><a id="selListTypeID" onclick="clickSelectListBox(this);" value="tab" class="up"><spring:message code="Cache.btn_apv_class_by"/></a></span>
							<div class="selList" style="width:77px;display: none;">
								<a class="listTxt select" value="tab" onclick="clickSelectListBoxData(this);" id="<spring:message code="Cache.btn_apv_class_by"/>"><spring:message code="Cache.btn_apv_class_by"/></a>
								<a class="listTxt" value="list" onclick="clickSelectListBoxData(this);" id="<spring:message code="Cache.btn_apv_total"/>"><spring:message code="Cache.btn_apv_total"/></a>
							</div>
						</div>
						<input type="button" value="<spring:message code='Cache.lbl_approval_recentlyApv'/>" class="opBtn" onclick="boxShowHide(this,'giBox');"> <!-- 최근기안 -->
						<input type="button" value="<spring:message code='Cache.lbl_approval_favoriteForm'/>" class="opBtn" onclick="boxShowHide(this,'faGi');"> <!-- 자주쓰는 기안 -->
						<div class="fRight searchBox02">
							<input type="text" id="searchInput" onkeypress="if (event.keyCode==13){ onClickSearchButton(); return false;}" style="width:260px;" placeholder="<spring:message code='Cache.msg_apv_001' />"><a onclick="onClickSearchButton();" class="btnSearchType01"><spring:message code="Cache.btn_search"/></a>
						</div>
					</div>
				</div>
				<!-- 최근기안  시작-->
				<div class="giBox" id="giBox" style="display:none;">
					<span class="giTit"><spring:message code='Cache.lbl_approval_recentlyApv'/></span> <!-- 최근기안 -->
					<dl class="giLeft" id="giLeft"></dl>
					<dl class="giRight" id="giRight"></dl>
				</div><!-- 최근기안  끝-->
				<!-- 자주쓰는 기안-->
				<ul class="faGi" id="faGi" style="display:none;"></ul>
				<!-- 자주쓰는 끝-->
				<div class="tabLine" style="height: auto;display:none;">
					<ul class="writeTab" id="writeTab"></ul>
				</div>
				<ul class="writeTapCont" id="writeTapCont" style="display:none;"></ul>
			</div>
			<!-- 본문 끝 -->
		</div>
	</div>
</div>

<script>
	$(document).ready(function () {
		setFormListTab();
		
		sessionObj = Common.getSession(); //전체호출
		//selSelectbind();
		getFormListDataType();
		$("#writeTapCont").show();
	});
</script>