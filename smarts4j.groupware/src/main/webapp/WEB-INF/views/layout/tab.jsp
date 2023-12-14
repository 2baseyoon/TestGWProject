<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="egovframework.coviframework.util.RedisDataUtil" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
	pageContext.setAttribute("isUseMail", RedisDataUtil.getBaseConfig("isUseMail"));
	pageContext.setAttribute("isUseAccount", RedisDataUtil.getBaseConfig("isUseAccount"));
%>
<!-- 
<div class="l-contents-tabs">
	<div id="fixedTabDiv" class="l-contents-tabs__fixed-tab l-contents-tabs__fixed-tab--active">
		<a id="fixedTabA" name="tap" url="/mail/layout/mail_Mail.do?CLSYS=mail&CLMD=user&CLBIZ=Mail" class="l-contents-tabs__main-tab">
			<i class="tab_eaccountingico_03"></i>
			<div class="l-contents-tabs__title">Home</div>
		</a>
	</div>
	
	<div id="eAccountTabList" class="l-contents-tabs__list">
		<div id="eAccountTabListDiv"></div>
		<div id="eAccountTapMoreDiv" class="l-contents-tabs__more-item" style="display:none">
			<a id="tapMoreA" class="l-contents-tabs__btn-more">
				<i class="i-etc--mail"></i>
			</a>
			<div id="eAccountTapMoreItems" class="l-contents-tabs__more-pop">
			</div>
		</div>
	</div>
</div>
	 -->
	 
	 
	<!-- 상단 탭 시작-->
	<div class="l-contents-tabs" style="display:none">
		<div id="l-contents-tabs__fixed-tab" class="l-contents-tabs__fixed-tab l-contents-tabs__fixed-tab--active l-contents-tabs__item--" >
			<a id="fixedTabA" name="tap" url="" class="l-contents-tabs__main-tab">
				<i class="tab_mailico_get"></i>
				<div class="l-contents-tabs__title"></div>
			</a>
		</div>
		
		<div class="l-contents-tabs__list" id="l-contents-tabs__list">
			<div id="mailTabListDiv"></div>
			<div id="mailTapMoreDiv" class="l-contents-tabs__more-item" style="display:none">
				<a id="tapMoreA" class="l-contents-tabs__btn-more">
					<i class="i-etc--mail"></i>
				</a>
				<div id="mailTapMoreItems" class="l-contents-tabs__more-pop">
				</div>
			</div>

		</div>
		
		<!-- l-contents-tabs__list에 추가되는 탭 -->
		<div class="l-contents-tabs__item l-contents-tabs__item--active" id="l-contents-tabs__item_sample" name="l-contents-tabs__item" style="display:none">
			<div class="l-contents-tabs__title"></div>
			<a class="l-contents-tabs__delete" name = "aTabDelete"><i class="i-cancle"></i></a>
		</div>
		
		<!-- l-contents-tabs__list에 추가되는 탭 -->
		<div class="l-contents-tabs__more-item" id="l-contents-tabs__more-item_sample" style="display:none">
			<a class="l-contents-tabs__btn-more"><i class="i-etc--mail"></i></a>
			<div class="l-contents-tabs__more-pop_sample">
				
			</div>
		</div>
		
		
	</div>
	

<c:if test="${isUseMail eq 'Y'}">
<script>
	//getMaxTabSize();
	
	var url = "/mail/layout/mail_Mail.do?CLSYS=mail&CLMD=user&CLBIZ=Mail";
	if(CFN_GetQueryString("mailBox") == "undefined"){
		$("#fixedTabA").attr("url",url+"&mailBox=INBOX");	
	}else{
		$("#fixedTabA").attr("url",url+"&mailBox="+decodeURIComponent(CFN_GetQueryString("mailBox")));
	}
	
	$('#mailTabListDiv').sortable({
		update:function(e,u){
			var order = $(this).sortable('toArray',{
					attribute : 'data-order'
			});
		}
	});
</script>
</c:if>