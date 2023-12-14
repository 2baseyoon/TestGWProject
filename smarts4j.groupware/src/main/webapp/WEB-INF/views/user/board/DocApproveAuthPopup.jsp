<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<style type="text/css">

</style>

<div class="layer_divpop ui-draggable docPopLayer" id="testpopup_p" style="width:685px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
	<div class="divpop_contents">
		<div class="popContent">
			<div class="middle">
				<table class="tableTypeRow">
					<caption><spring:message code='Cache.lbl_Doc_requestAuth'/></caption>	<!-- 문서권한 요청 -->
					<colgroup>
						<col style="width: 21.66%;">
						<col style="width: auto;">
					</colgroup>
					<tbody>
						<tr>
							<th><spring:message code='Cache.lbl_Title'/></th>	<!-- 제목 -->
							<td>
								<div class="box">
									<span id="spanSubject" class="title"></span>
								</div>
							</td>
						</tr>
						<tr>
							<th><spring:message code='Cache.lbl_DocCate'/></th>	<!-- 문서분류 -->
							<td>
								<div class="box">
									<div id="divFolderPath" class="path">
										
									</div>
								</div>
							</td>
						</tr>
						<tr>
							<th><spring:message code='Cache.lbl_Doc_currentAcl'/></th>	<!-- 현재 권한 -->
							<td>
								<ul id="ulCurrentACL" class="setList requestList">
									<li>
										<strong>[S]<spring:message code='Cache.lbl_SecurityAcl'/></strong>	<!-- 보안권한 -->
										<div>
											<p class="alarm txtOn">
												<a id="btnSecurity" href="#" class="onOffBtn"><span></span></a>
												<span class="offTxt"><spring:message code="Cache.lbl_Reject"/></span><span class="onTxt"><spring:message code="Cache.lbl_Allow"/></span>
											</p>
										</div>
									</li>
									<li>
										<strong>[D]<spring:message code='Cache.lbl_DeleteAcl'/></strong>	<!-- 삭제권한 -->
										<div>
											<p class="alarm txtOn">
												<a id="btnDelete" href="#" class="onOffBtn"><span></span></a>
												<span class="offTxt"><spring:message code="Cache.lbl_Reject"/></span><span class="onTxt"><spring:message code="Cache.lbl_Allow"/></span>
											</p>
										</div>
									</li>
									<li>
										<strong>[M]<spring:message code="Cache.lbl_ModifyAcl"/></strong>	<!-- 수정권한 -->
										<div>
											<p class="alarm txtOn">
												<a id="btnModify" href="#" class="onOffBtn"><span></span></a>
												<span class="offTxt"><spring:message code="Cache.lbl_Reject"/></span><span class="onTxt"><spring:message code="Cache.lbl_Allow"/></span>
											</p>
										</div>
									</li>
									<li>
										<strong>[E]<spring:message code='Cache.lbl_ExecuteAcl'/></strong>	<!-- 실행 권한 -->
										<div>
											<p class="alarm txtOn">
												<a id="btnExecute" href="#" class="onOffBtn"><span></span></a>
												<span class="offTxt"><spring:message code="Cache.lbl_Reject"/></span><span class="onTxt"><spring:message code="Cache.lbl_Allow"/></span>	<!-- 거부, 허용 -->
											</p>
										</div>
									</li>
									<li>
										<strong>[R]<spring:message code='Cache.lbl_ReadAcl'/></strong>		<!-- 읽기권한 -->
										<div>
											<p class="alarm txtOn">
												<a id="btnRead" href="#" class="onOffBtn"><span></span></a>
												<span class="offTxt"><spring:message code="Cache.lbl_Reject"/></span><span class="onTxt"><spring:message code="Cache.lbl_Allow"/></span>
											</p>
										</div>
									</li>
								</ul>
							</td>
						</tr>
						<tr>
							<th><spring:message code='Cache.lbl_Owner'/></th>	<!-- 소유자 -->
							<td>
								<input type="hidden" id="hidOwnerCode" value="" />
								<div id="divOwnerCode" class="box">
								</div>
							</td>
						</tr>
						<tr>
							<th><spring:message code='Cache.lbl_Requester'/></th>	<!-- 요청자 -->
							<td>
								<div id="divUserCode" class="box">
								</div>
							</td>
						</tr>
						<tr>
							<th id="thRequestDate"><spring:message code='Cache.lbl_RequestDate'/></th>	<!-- 요청일자 -->
							<td>
								<div id="divRequestDate" class="box">
									<!-- 요청일자 -->
								</div>
							</td>
						</tr>
						<tr>
							<th><spring:message code='Cache.lbl_AclRequestComment'/></th>	<!-- 권한요청 사유 -->
							<td>
								<div id="divRequestMessage" class="box">
									<!-- 요청사유 -->
								</div>
							</td>
						</tr>
						<tr>
							<th><spring:message code='Cache.lbl_AclRequest'/></th> <!-- 권한요청 -->
							<td>
								<ul id="ulRequestACL" class="setList requestList">
									<li>
									<strong>[S]<spring:message code='Cache.lbl_SecurityAcl'/></strong>	<!-- 보안권한 -->
										<div>
											<p class="alarm txtOn">
												<a id="btnRequestSecurity" href="#" class="onOffBtn"><span></span></a>
												<span class="offTxt"><spring:message code="Cache.lbl_Reject"/></span><span class="onTxt"><spring:message code="Cache.lbl_Allow"/></span>
											</p>
										</div>
									</li>
									<li>
										<strong>[D]<spring:message code='Cache.lbl_DeleteAcl'/></strong>	<!-- 삭제 권한 -->
										<div>
											<p class="alarm txtOn">
												<a id="btnRequestDelete" href="#" class="onOffBtn"><span></span></a>
												<span class="offTxt"><spring:message code="Cache.lbl_Reject"/></span><span class="onTxt"><spring:message code="Cache.lbl_Allow"/></span>
											</p>
										</div>
									</li>
									<li>
										<strong>[M]<spring:message code="Cache.lbl_ModifyAcl"/></strong>	<!-- 수정 권한 -->
										<div>
											<p class="alarm txtOn">
												<a id="btnRequestModify" href="#" class="onOffBtn"><span></span></a>
												<span class="offTxt"><spring:message code="Cache.lbl_Reject"/></span><span class="onTxt"><spring:message code="Cache.lbl_Allow"/></span>
											</p>
										</div>
									</li>
									<li>
										<strong>[E]<spring:message code='Cache.lbl_ExecuteAcl'/></strong>	<!-- 실행 권한 -->
										<div>
											<p class="alarm txtOn">
												<a id="btnRequestExecute" href="#" class="onOffBtn"><span></span></a>
												<span class="offTxt"><spring:message code="Cache.lbl_Reject"/></span><span class="onTxt"><spring:message code="Cache.lbl_Allow"/></span>	<!-- 거부, 허용 -->
											</p>
										</div>
									</li>
									<li>
										<strong>[R]<spring:message code='Cache.lbl_ReadAcl'/></strong>	<!-- 읽기 권한 -->
										<div>
											<p class="alarm txtOn">
												<a id="btnRequestRead" href="#" class="onOffBtn"><span></span></a>
												<span class="offTxt"><spring:message code="Cache.lbl_Reject"/></span><span class="onTxt"><spring:message code="Cache.lbl_Allow"/></span>
											</p>
										</div>
									</li>
								</ul>
							</td>
						</tr>
						<tr>
							<th><spring:message code='Cache.lbl_ReasonForProcessing'/></th>
							<td>
								<div class="divRequestMessage">
									<textarea id="txtComment" class="HtmlCheckXSS ScriptCheckXSS" cols="20" rows="3" title="처리사유입력"></textarea>
								</div>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
			<div class="bottom">
				<a id="btnAllow" href="#" class="btnTypeDefault btnTypeBg" onclick="javascript:board.allowMessage();"><spring:message code='Cache.btn_Approval2'/></a>	<!-- 승인 -->
				<a id="btnDenie" href="#" class="btnTypeDefault" onclick="javascript:board.denieMessage();"><spring:message code="Cache.btn_Reject"/></a>				<!-- 거부 -->
				<a href="#" class="btnTypeDefault" onclick="javascript:Common.Close();"><spring:message code="Cache.btn_Cancel"/></a>		<!-- 취소 -->
			</div>
			</div>
		</div>
	</div>

<script>
	var folderID = CFN_GetQueryString("folderID");
	var messageID = CFN_GetQueryString("messageID");
	var version = CFN_GetQueryString("version");
	var requestID = CFN_GetQueryString("requestID");
	var requestorCode = CFN_GetQueryString("requestorCode");
	var communityID = '';	//parameter 채우기용
	var currentCreateAuth = '';
	var requestCreateAuth = '';

	function getRequestAcl(){
		$.ajax({
	    	type:"POST",
	    	url: "/groupware/board/selectRequestAclDetail.do",
	    	data: {
		    	'requestID': requestID
		    },
	    	dataType : 'json',
	    	success:function(res){
	    		if(res.status=='SUCCESS'){
		    		var data = res.data;
		    		$('#divUserCode').text(data.RequestorName);
		    		$('#divRequestDate').text(CFN_TransLocalTime(data.RequestDate) + " " + Common.getSession("UR_TimeZoneDisplay"));
		    		$('#divRequestMessage').text(data.RequestMessage);
		    		
		    		// 현재권한 설정
		    		var currentAclList = data.CurrentAclList;
		    		currentAclList.indexOf("S")!=-1?$('#btnSecurity').addClass('on'):"";
		    		currentAclList.indexOf("D")!=-1?$('#btnDelete').addClass('on'):"";
		    		currentAclList.indexOf("M")!=-1?$('#btnModify').addClass('on'):"";
		    		currentAclList.indexOf("E")!=-1?$('#btnExecute').addClass('on'):"";
		    		currentAclList.indexOf("R")!=-1?$('#btnRead').addClass('on'):"";
		    		
		    		currentCreateAuth = currentAclList.charAt(1);
		    		
		    		// 요청권한 설정
		    		var requestAclList = data.RequestAclList;
		    		requestAclList.indexOf("S")!=-1?$('#btnRequestSecurity').addClass('on'):"";
		    		requestAclList.indexOf("D")!=-1?$('#btnRequestDelete').addClass('on'):"";
		    		requestAclList.indexOf("M")!=-1?$('#btnRequestModify').addClass('on'):"";
		    		requestAclList.indexOf("E")!=-1?$('#btnRequestExecute').addClass('on'):"";
		    		requestAclList.indexOf("R")!=-1?$('#btnRequestRead').addClass('on'):"";
		    		
		    		requestCreateAuth = requestAclList.charAt(1);

		    		if(data.ActType != "R"){
			    		$('#btnAllow, #btnDenie').hide();
			    	}
	    		}else{
	    			Common.Warning("<spring:message code='Cache.msg_sns_03'/>");/* 저장 중 오류가 발생하였습니다. */
	    		}
	    	}, 
	  		error:function(error){
	  			Common.Warning("<spring:message code='Cache.msg_sns_03'/>");
	  		}
	    });
	}

	function setAclList(){
		var aclList = '';
		aclList += $('#btnRequestSecurity').hasClass('on')?"S":"_";
		aclList += requestCreateAuth;
		aclList += $('#btnRequestDelete').hasClass('on')?"D":"_";
		aclList += $('#btnRequestModify').hasClass('on')?"M":"_";
		aclList += $('#btnRequestExecute').hasClass('on')?"E":"_";
		aclList += $('#btnRequestRead').hasClass('on')?"R":"_";
		return aclList;
	}

	$(function () {
		$("#thRequestDate").text($("#thRequestDate").text());
		
		board.getBoardConfig(folderID);		
		board.selectMessageDetail('', 'Doc', version, messageID, folderID);
		
		$('.path').html(board.renderFolderPath());
		
		$('#divOwnerCode').text(g_messageConfig.OwnerName);
		$('#spanSubject').text(g_messageConfig.Subject);
		$('#hidOwnerCode').val(g_messageConfig.OwnerCode);
		
		getRequestAcl();	// 현재권한 및 요청권한 조회
		//setCurrentAcl();
		
		//스위치 on/off 이벤트 바인드
		$("#ulRequestACL .alarm").on('click', function(){
			$(this).find('.onOffBtn').hasClass('on') == true?$(this).find('.onOffBtn').removeClass('on'):$(this).find('.onOffBtn').addClass('on');
		});
	});
</script>
