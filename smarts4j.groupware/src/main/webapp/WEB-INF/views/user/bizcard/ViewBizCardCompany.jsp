<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta http-equiv='cache-control' content='no-cache'> 
	<meta http-equiv='expires' content='0'> 
	<meta http-equiv='pragma' content='no-cache'>
	<jsp:include page="/WEB-INF/views/cmmn/include.jsp"></jsp:include>
	<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>
</head>

<body>	
	<div class="layer_divpop ui-draggable popBizCardView" id="testpopup_p" style="width:500px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<!-- <div class="pop_header" id="testpopup_ph">
				<h4 class="divpop_header ui-draggable-handle" id="testpopup_Title"><span class="divpop_header_ico">연락처 상세 보기</span></h4><a class="divpop_close" id="testpopup_px" style="cursor: pointer;"></a><a class="divpop_window" id="testpopup_LayertoWindow" style="cursor: pointer;" onclick="Common.LayerToWindow('layerpopuptest.do?as=ads', 'testpopup', '331px', '270px', 'both')"></a><a class="divpop_full" style="cursor: pointer;" onclick="Common.ScreenFull('testpopup', $(this))"></a><a class="divpop_mini" style="cursor: pointer;" onclick="Common.ScreenMini('testpopup', $(this))"></a>
			</div> -->
			<div class="popContent">
				<div class="popContTop business"><!-- 명함일때 클래스 nameCard, 업체일때 클래스 business 추가 -->
					<div class="photoArea">
						<img id="bizCardThumbnail" /> <!--  src="/HtmlSite/smarts4j_n/bizcard/resources/images/@img_business_card.jpg" -->
					</div>
					<dl class="infoArea">
						<dt><strong><span id="spnComName"></span></strong></dt>
						<dd class="division">
							<strong>(우) <span id="spnComZipcode"></span></strong> <span id="spnComAddress"></span>
						</dd>
					</dl>
				</div>
				<div class="rowTypeWrap contDetail">
					<dl>
						<dt><spring:message code='Cache.lbl_Email2' /></dt>
						<dd><span class="icoIrComm icoMail"><span id="spanEmail"></span></span></dd>
					</dl>
					<dl>
						<dt><spring:message code='Cache.lbl_Office' /></dt>
						<dd><span id="spanTelPhone"></span></dd>
					</dl>
					<dl>
						<dt><spring:message code='Cache.lbl_Office_Fax' /></dt>
						<dd><span id="spanFAX"></span></dd>
					</dl>
					<dl>
						<dt><spring:message code='Cache.lbl_AnniversarySchedule' /></dt>
						<dd><span id="spanAnniversary"></span></dd>
					</dl>
					<dl>
						<dt><spring:message code='Cache.lbl_homepage' /></dt>
						<dd><span id="spanComWebSite"></span></dd>
					</dl>
					<dl>
						<dt><spring:message code='Cache.lbl_Memo' /></dt>
						<dd><textarea rows="2" id="txtMemo" readonly="readonly"></textarea></dd>
					</dl>
				</div>
				<div class="btnPosRWrap">
					<!-- <a href="#" class="icoIrComm btnOutput">내보내기</a> -->
				</div>
				<div class="popBtnWrap">
					<a href="#" class="btnTypeDefault" onclick="modifyBizCard();"><spring:message code='Cache.lbl_Modify' /></a>
					<a href="#" class="btnTypeDefault" onclick="deleteBizCard();"><spring:message code='Cache.lbl_delete' /></a>
					<a href="#" class="btnTypeDefault" onclick="closeBizCard();"><spring:message code='Cache.lbl_close' /></a>
				</div>
			</div>
		</div>	
	</div>
</body>

<script>
	$(function() {		
		$.ajaxSetup({
		     async: true
		});
		
		$.getJSON('getBizCardCompanyView.do', {'BizCardID' : "${BizCardID}"}, function(d) {
			d = d.company[0];
			if(d.ImagePath == ""&& d.ImagePath != undefined) {
				$("#bizCardThumbnail").attr('src', '/HtmlSite/smarts4j_n/covicore/resources/images/covision/no_img.gif');
			} else {
				$("#bizCardThumbnail").attr('src', (d.ImagePath)); //.replace('192.168.11.126', 'localhost')
			}
			$("#bizCardThumbnail").css('width', '100%');
			$("#bizCardThumbnail").css('height', '100%');
			
			$("#spnComName").html(d.ComName);
			$("#spnComZipcode").html(d.ComZipCode);
			$("#spnComAddress").html(d.ComAddress);
			$("#txtMemo").html(d.Memo);
			$("#spanAnniversary").html(d.AnniversaryText);
			$("#spanTelPhone").html(d.TelPhone.replaceAll(";", "<br />"));
			$("#spanFAX").html(d.FAX.replaceAll(";", "<br />"));
			$("#spanEmail").html(d.Email.replaceAll(";", "<br /><span class='icoIrComm icoMail'></span>"));
			$("#spanComWebSite").html(d.ComWebSite);
		}).error(function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("getBizCardCompanyView.do", response, status, error);
		});
	});
	
	function modifyBizCard() {
		parent.location.href = "ModifyBizCard.do" + "?CLSYS=bizcard&CLMD=user&CLBIZ=Bizcard&mnp=" + encodeURIComponent(0) + "&BizCardID=" + encodeURIComponent("${BizCardID}") + "&TypeCode=C";
		
		console.dir(event);
		// 이벤트 기본동작 방지
		event.preventDefault ? event.preventDefault() : (event.returnValue = false);	
		// 버블링 방지
		event.stopPropagation ? event.stopPropagation() : (event.cancelBubble = true);	
		
		return false;
	}
	
	function deleteBizCard() {
		if("${BizCardID}" != "" && "${BizCardID}" != undefined) {
			$.ajaxSetup({
			     async: true
			});
			
			$.ajax({
				url : "/groupware/bizcard/DeleteBizCard.do",
				type : "POST",
				data : {
					"BizCardID" :  "${BizCardID}",
					"TypeCode" :  'C'
				},
				success : function(d) {
					try {
						Common.Inform("<spring:message code='Cache.msg_deletedOK'/>", 'Information Dialog', function (result) {
							parent.window.location.reload();
				        }); 
					} catch(e) {
						coviCmn.traceLog(e);
					}
				},
				error:function(response, status, error){
				     //TODO 추가 오류 처리
				     CFN_ErrorAjax("DeleteBizCard.do", response, status, error);
				}
			});
		}
	}
	
	function closeBizCard() {
		Common.Close();
	}
</script>