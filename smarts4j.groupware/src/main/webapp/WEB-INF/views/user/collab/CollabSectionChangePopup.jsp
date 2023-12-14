<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"
	import="egovframework.baseframework.util.SessionHelper,egovframework.baseframework.util.PropertiesUtil, egovframework.baseframework.util.SessionHelper,egovframework.coviframework.util.RedisDataUtil"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!doctype html>
<html lang="ko">
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<style>
	ul li{width: 100%;height:30px; font-size: 13px;font-weight: bold;padding-left: 15px;padding-top: 8px; margin:5px 0px;background-color:#fff;border:1px solid #ddd;border-radius:5px;box-sizing:border-box;box-shadow: 3px 3px 6px 0px rgba(0,0,0,0.16);overflow:hidden;}
	li:hover { cursor: pointer; }
	.section_placeholder { border:1px dotted black; height:30px; margin-left:auto; margin-right:auto; background-color:#eee; }
</style>

<body>	
	<div class="collabo_popup_wrap">
		<div class="collabo_table_wrap">
			
			<div id="sectionList">
				<ul>
				<c:forEach items="${secList}" var="item" varStatus="status">
					<li data-sectionseq="${item.SectionSeq}" data-sectionname="${item.SectionName}">
						${item.SectionName}
					</li>
				</c:forEach>
				</ul>
			</div>
			
		</div>				
		<div class="popBtnWrap">
			<a href="#" class="btnTypeDefault btnTypeBg" id="btnSave"><spring:message code='Cache.lbl_Save'/></a>
			<a href="#" class="btnTypeDefault" id="btnClose"><spring:message code='Cache.lbl_Cancel'/></a>
		</div>
	</div>
</body>
<script type="text/javascript">
var callbackParam =  {"prjSeq":'${prjSeq}', "prjType":'${prjType}', "taskSeq":'${taskSeq}'};
var sectionSeq = "";
var sectionName = "";
var collabSectionChange = {
	objectInit : function(){			
		this.addEvent();
	},
	addEvent : function(){
		
		$("#sectionList li").on('click', function(e){
			sectionSeq = $(this).data("sectionseq");
			sectionName = $(this).data("sectionname");
			
			$("#sectionList li").removeClass("section_placeholder");
			$(this).addClass("section_placeholder");
		});
		
		$("#btnSave").on('click', function(){
			collabSectionChange.sectionSave();
		});
		
		$("#btnClose").on('click', function(){
			Common.Close();
		});
	},
	sectionSave : function(){
		
		if(sectionSeq == ""){
			Common.Inform("<spring:message code='Cache.ACC_msg_noChange'/>");	//변경사항이 없습니다.
			return;
		}
		
		$.ajax({
			type:"POST",
			contentType: 'application/json; charset=utf-8',
			dataType: 'json',
			data: JSON.stringify({
				"prjSeq":'${prjSeq}'
				, "prjType":'${prjType}'
				, "taskSeq":'${taskSeq}'
				, "sectionseq":sectionSeq	
			}),
			url:"/groupware/collabProject/saveSectionChange.do",
			success:function (data) {
				if(data.status == "SUCCESS"){
					Common.Inform("<spring:message code='Cache.msg_Changed'/>");	//변경되었습니다
					
					callbackParam["SectionSeq"] = sectionSeq;
					callbackParam["SectionName"] = sectionName;
					
					parent.collabProjectAdd.changeSection(callbackParam);	//새로고침
					
					Common.Close();
				}
				else{
					Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"); //	오류가 발생했습니다. 관리자에게 문의바랍니다
				}
			},
			error:function (request,status,error){
				Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
			}
		});
	}
}

$(document).ready(function(){
	collabSectionChange.objectInit();
});

</script>