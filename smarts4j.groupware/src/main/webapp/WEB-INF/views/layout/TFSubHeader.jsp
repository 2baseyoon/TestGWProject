<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<script type="text/javascript">
$(function(){
	setSubHeader();
});
function setSubHeader(){
	 $.ajax({
		url:"/groupware/layout/userTF/TFSubHeaderSetting.do",
		type:"POST",
		async:true,
		data:{
			communityID : cID
		},
		success:function (e) {
			
			if(e.list.length > 0){
				$(e.list).each(function(i,v){
					$("#toTalVcnt").html(v.totalVisitCnt);
					$("#toDayVcnt").html(v.visitCnt);
					$("#CDate").html(CFN_TransLocalTime(v.RegProcessDate,_ServerDateSimpleFormat));
					$("#CMemberCnt").html(v.MemberCNT);
				});
			}
			
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/groupware/layout/userTF/TFSubHeaderSetting.do", response, status, error); 
		}
	}); 
}

</script>

<ul class="clearFloat">
	<li><spring:message code='Cache.lbl_TotalVisitors'/> : <span id="toTalVcnt"></span></li>
	<li><spring:message code='Cache.lbl_TodayVisitors'/> : <span id="toDayVcnt"></span></li>
	<li><spring:message code='Cache.lbl_Establishment_Day'/> : <span id="CDate"></span></li>
	<li><span class="tbViewCount" id="CMemberCnt"></span></li>
</ul>
