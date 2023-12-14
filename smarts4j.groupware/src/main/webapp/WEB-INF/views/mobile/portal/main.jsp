<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@page import="egovframework.baseframework.util.PropertiesUtil,egovframework.coviframework.util.RedisDataUtil,egovframework.coviframework.util.SessionCommonHelper,egovframework.coviframework.util.DicHelper"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib uri="/WEB-INF/tlds/covi.tld" prefix="covi" %>
<style>

<%
if (SessionCommonHelper.getSessionMapKey("PortalOption","mbPortalBg","image-1").equals("image-custom")){ 
	out.println(".ui_portal .portal_background[data-background=image-custom] {background-image:url('/covicore/common/photo/photo.do?img="+SessionCommonHelper.getSessionMapKey("PortalOption","portalBgPath","")+"')}");
}
if (!SessionCommonHelper.getSession("DomainImagePath").equals("")  && SessionCommonHelper.getSession("DomainImagePath").indexOf(";") > 0){
	String[] domainImage = SessionCommonHelper.getSession("DomainImagePath").split(";",-1);

	if (domainImage.length>1 && !domainImage[1].equals("")){
		out.println("html:not([data-mode=dark]) .ui_portal[data-text-color=black] .portal_global .global_logo a { background-image: url('/covicore/common/logo/"+domainImage[1]+".do') !important}");
		
		if (domainImage.length>4 && !domainImage[4].equals("")){
			out.println(".ui_portal[data-text-color=white] .global_logo a { background-image: url('/covicore/common/logo/"+domainImage[4]+".do') !important}");
		}else{
			out.println(".ui_portal[data-text-color=white] .global_logo a { background-image: url('/covicore/common/logo/"+domainImage[1]+".do') !important}");
		}
	}
	
}
%>
</style>

<div data-role="page" id="portal_main_page">
 <div class="ui_app ui_portal" data-text-color="<%=SessionCommonHelper.getSessionMapKey("PortalOption","mbPortalText","black")%>">
<script type="text/javascript">
	//webpart script
	var gwPortal = {};
	function mobile_portal_webpart(){
		<c:forEach var="list"  items="${webpart}" varStatus="status">
			try{
				<c:if test="${fn:length(list.initMethod )>0}">
					let WP${list.WebpartID}_data ;		
					let WP${list.WebpartID}_json ;
					<c:if test="${fn:length(list.data)>0}">WP${list.WebpartID}_data = ${list.data};</c:if>				
					<c:if test="${fn:length(list.ExtentionJSON)>0}">WP${list.WebpartID}_json = ${list.ExtentionJSON};</c:if>				
					gwPortal['${list.WebpartID}'] =  ${list.JsModuleName}Obj(WP${list.WebpartID}_data, WP${list.WebpartID}_json, 'Portal', 'WP${list.WebpartID}');
				</c:if>		
			}catch (e){
				mobile_comm_log(e);
			}			
		</c:forEach>
		
		<c:forEach var="list"  items="${myWidget}" varStatus="status">
			try{
				changeWebpartLayer('WP${list.WebpartID}','Widget', ${list.ExtentionJSON},'${list.DisplayName}');
				<c:if test="${fn:length(list.ScriptMethod )>0}">
					let WP${list.WebpartID}_data ;		
					let WP${list.WebpartID}_json ;
					<c:if test="${fn:length(list.data)>0}">WP${list.WebpartID}_data = ${list.data};</c:if>				
					<c:if test="${fn:length(list.ExtentionJSON)>0}">WP${list.WebpartID}_json = ${list.ExtentionJSON};</c:if>				
					gwPortal['${list.WebpartID}'] =  ${list.JsModuleName}Obj(WP${list.WebpartID}_data, WP${list.WebpartID}_json, 'Widget', 'WP${list.WebpartID}');
				</c:if>		
				
				<c:if test="${not empty list.ExtentionJSON  && not empty list.ExtentionJSON.swiperInfo }"> 
    			coviUtil.drawSwiper('WP${list.WebpartID}',${list.ExtentionJSON.swiperInfo});
    		</c:if>
	    	
			}catch (e){
				mobile_comm_log(e);
			}	
		</c:forEach>
		
		<c:forEach var="list"  items="${myContents}" varStatus="status">
			try{
				changeWebpartLayer('WP${list.WebpartID}','Contents', ${list.ExtentionJSON},'${list.DisplayName}');
				<c:if test="${fn:length(list.ScriptMethod )>0}">
					let WP${list.WebpartID}_data ;		
					let WP${list.WebpartID}_json ;
					<c:if test="${fn:length(list.data)>0}">WP${list.WebpartID}_data = ${list.data};</c:if>				
					<c:if test="${fn:length(list.ExtentionJSON)>0}">WP${list.WebpartID}_json = ${list.ExtentionJSON};</c:if>				
					gwPortal['${list.WebpartID}'] =  ${list.JsModuleName}Obj(WP${list.WebpartID}_data, WP${list.WebpartID}_json, 'Contents', 'WP${list.WebpartID}');
				</c:if>		
				
				<c:if test="${not empty list.ExtentionJSON  && not empty list.ExtentionJSON.swiperInfo }"> 
	    			coviUtil.drawSwiper('WP${list.WebpartID}',${list.ExtentionJSON.swiperInfo});
	    		</c:if>
			}catch (e){
				mobile_comm_log(e);
			}	
		</c:forEach>
	}
	
	${javascriptString}
	${myWidgetScripts}
	${myContentsScripts}
	var linkMail = '${linkMail}';
	
</script>
	<% 
		String isSaaS = PropertiesUtil.getGlobalProperties().getProperty("isSaaS"); 
		String cssPath = PropertiesUtil.getGlobalProperties().getProperty("css.path");	
	%>
 	<div class="portal_background" data-background="<%=SessionCommonHelper.getSessionMapKey("PortalOption","mbPortalBg","black-1")%>"></div>
    <div class="portal_dim" <%=(SessionCommonHelper.getSessionMapKey("PortalOption","mbDim","").equals("Y")?"":"hidden")%>></div>
    <div class=portal_global>
	    <div class="global_app_bar">
	    	<div class="global_logo">
                 <a href="#" onclick="javascript:mobile_comm_go('/groupware/mobile/portal/main.do','');"><span class="blind">코비젼</span></a>
             </div>
		    <div class="global_utility">
	              <button type="button" class="utility_button utility_alarm" onclick="javascript:mobile_comm_go('/groupware/mobile/portal/integrated.do','Y');"><span>알림</span><em class="ui_badge"></em></button>
	              <button type="button" class="utility_button utility_change" onclick="javascript:$('#mobile_home_addjobpop').show();" style="display: none;"><span>겸직변경</span></button>
	              <button type="button" class="utility_avatar" id="setting_toggle">
	                  <span class="ui_avatar avatar"><img src="/covicore/common/photo/photo.do?img=<%=SessionCommonHelper.getSession("PhotoPath")%>" alt="아바타"  onerror="mobile_comm_imageerror(this, true)"></span>
	                  <span class="info">
		                <strong><%=SessionCommonHelper.getSession("UR_Name")%> <%=SessionCommonHelper.getSession("UR_JobPositionName")%></strong>
		                <em><%=SessionCommonHelper.getSession("DEPTNAME")%></em>
			          </span>
	              </button>
	          </div>
	    </div>
	    <div class="global_alarm">
	        <div class="my_link new" type="integrated">
	            <a href="javascript: mobile_comm_go('/groupware/mobile/portal/integrated.do','Y');"><i class="ico_my_link01"></i></a>
	        </div>
	    </div>            
	    <div class="global_nav">
	        <div class="nav_scroll">
	            <div class="nav_list">
	                <ul id="portal_main_tab">
	                	<c:set var="data_index" value="0"/>
	                	<c:if test = "${fn:contains(MobileHomeTab, 'C')}"> 
	                    <li tab="C"><button type="button" class="tab" data-index="${data_index}" aria-selected="false"><span><spring:message code='Cache.lbl_Content'/></span></button></li>
	                    <c:set var="data_index" value="${data_index+1}"/>
	                    </c:if>
	                	<c:if test = "${fn:contains(MobileHomeTab, 'P')}">
	                    <li tab="P"><button type="button" class="tab" data-index="${data_index}" aria-selected="true"><span><spring:message code='Cache.WebPartBizSection_Portal'/></span></button></li>
	                    <c:set var="data_index" value="${data_index+1}"/>
	                    </c:if>
	                	<c:if test = "${fn:contains(MobileHomeTab, 'M') &&  isUseMail eq 'Y'}">
	                    <li tab="M"><button type="button" class="tab" data-index="${data_index}" aria-selected="false"><spring:message code='Cache.CPMail_mail_inbox'/></span></button></li>
	                    <c:set var="data_index" value="${data_index+1}"/>
	                    </c:if>
	                	<c:if test = "${fn:contains(MobileHomeTab, 'A')}">
	                    <li tab="A"><button type="button" class="tab" data-index="${data_index}" aria-selected="false"><spring:message code='Cache.lbl_apv_appDoc'/></span></button></li>
	                    <c:set var="data_index" value="${data_index+1}"/>
	                    </c:if>
	                	<c:if test = "${fn:contains(MobileHomeTab, 'B')}">
	                    <li tab="B"><button type="button" class="tab" data-index="${data_index}" aria-selected="false"><spring:message code='Cache.WPBoardTabListType_RECENT'/></span></button></li>
	                    <c:set var="data_index" value="${data_index+1}"/>
	                    </c:if>
	                </ul>
	            </div>
	        </div>
	    </div>
	</div>
    
    <div class="portal_root">
         <div class="swiper portal_swiper">
             <div class="swiper-wrapper">
             	<!--  mycontents tab dataindex 세팅-->
               	 <c:set var="data_index" value="0"/>
             	 <c:if test="${fn:contains(MobileHomeTab, 'C')}">	
                 <div class="swiper-slide portal-panel" hidden data-hash="content" data-index="${data_index}" data-tab="C">
                 	 <div data-custom-scrollbar>
                           <div class="portal_content portal_slide_content">
                            <div class="ui_grid">
		    	              <c:forEach var="list"  items="${myContents}" varStatus="status">
								<div class="grid_item widget_card portal_widget ${list.Reserved3}"  id="WP${list.WebpartID}"><!--${list.DisplayName} ${list.JsFilePath}-->
								${covi:convertBase64Dec(list.viewHtml)}
								</div>
		                       </c:forEach> 
                            </div>
                        </div>
                       </div>
                </div>
                <c:set var="data_index" value="${data_index+1}"/>
                </c:if>
                <!-- portal tab-->
                <c:if test="${fn:contains(MobileHomeTab, 'P')}">	
                <div class="swiper-slide portal-panel" data-hash="portal" data-index="${data_index}" data-tab="P">
				     <div data-custom-scrollbar>
                      <div class="portal_main portal_slide_content">
						<c:forEach var="list"  items="${webpart}" varStatus="status">
							<div id="WP${list.WebpartID}" data-wepart-id="${list.WebpartID}" style="min-height:${list.MinHeight}px;" isload="Y"><!--${list.DisplayName} ${list.JsFilePath}-->
							${covi:convertBase64Dec(list.viewHtml)}
							</div>
			            </c:forEach>	
			             
                        <div class="ui_grid" >
							<c:forEach var="list"  items="${myWidget}" varStatus="status">
                                   <div id="WP${list.WebpartID}" data-wepart-id="${list.WebpartID}"  class="grid_item portal_widget ${list.Reserved3} translucent">
                                   	<div class="widget_card">
									${covi:convertBase64Dec(list.viewHtml)}
									</div>
                                   </div>
                                </c:forEach> 
                           	</div>
                           </div>
                        </div>   
                </div>    
                <c:set var="data_index" value="${data_index+1}"/>
                </c:if>
                <!-- mail tab -->
                <c:if test = "${fn:contains(MobileHomeTab, 'M') &&  isUseMail eq 'Y'}">
                <div class="swiper-slide post-swiper portal-panel" data-hash="mail" data-index="${data_index}" data-tab="M">
					<div class="portal_post portal_mail portal_slide_content">
						<div class="post_head">
							<h3><spring:message code="Cache.CPMail_mail_inbox" /></h3> 
							<a href="javascript:mobile_comm_go('/mail/mobile/mail/List.do')" class="more"><span><spring:message code="Cache.lbl_MoreView" /></span></a>
						</div>
						 <div class="post_container">
                               <div class="list_panel">
                                   <div data-custom-scrollbar>
                                       <div class="post_list">
                                           <ul id="ulPortalMailList">
                                           	<li>
                                                   <a href="#" class="post_item">
                                                      <span class="ui_avatar bg02"><span></span></span>
                                                       <span class="content">
                                                           <strong class="title"><span class="text" style="background-color: #e0e0e0; width: 100%;">&nbsp;</span></strong>
                                                           <em class="meta" style="width: 20%; background-color: #ededed;">&nbsp;</em>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                       </span>
                                                   </a>
                                               </li>
                                               <li>
                                                   <a href="#" class="post_item">
                                                      <span class="ui_avatar bg02"><span></span></span>
                                                       <span class="content">
                                                           <strong class="title"><span class="text" style="background-color: #e0e0e0; width: 100%;">&nbsp;</span></strong>
                                                           <em class="meta" style="width: 20%; background-color: #ededed;">&nbsp;</em>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                       </span>
                                                   </a>
                                               </li>
                                               <li>
                                                   <a href="#" class="post_item">
                                                      <span class="ui_avatar bg02"><span></span></span>
                                                       <span class="content">
                                                           <strong class="title"><span class="text" style="background-color: #e0e0e0; width: 100%;">&nbsp;</span></strong>
                                                           <em class="meta" style="width: 20%; background-color: #ededed;">&nbsp;</em>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                       </span>
                                                   </a>
                                               </li>
                                               <li>
                                                   <a href="#" class="post_item">
                                                      <span class="ui_avatar bg02"><span></span></span>
                                                       <span class="content">
                                                           <strong class="title"><span class="text" style="background-color: #e0e0e0; width: 100%;">&nbsp;</span></strong>
                                                           <em class="meta" style="width: 20%; background-color: #ededed;">&nbsp;</em>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                       </span>
                                                   </a>
                                               </li>
                                               <li>
                                                   <a href="#" class="post_item">
                                                      <span class="ui_avatar bg02"><span></span></span>
                                                       <span class="content">
                                                           <strong class="title"><span class="text" style="background-color: #e0e0e0; width: 100%;">&nbsp;</span></strong>
                                                           <em class="meta" style="width: 20%; background-color: #ededed;">&nbsp;</em>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                       </span>
                                                   </a>
                                               </li>
                                               <li>
                                                   <a href="#" class="post_item">
                                                      <span class="ui_avatar bg02"><span></span></span>
                                                       <span class="content">
                                                           <strong class="title"><span class="text" style="background-color: #e0e0e0; width: 100%;">&nbsp;</span></strong>
                                                           <em class="meta" style="width: 20%; background-color: #ededed;">&nbsp;</em>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                       </span>
                                                   </a>
                                               </li>
                                               <li>
                                                   <a href="#" class="post_item">
                                                      <span class="ui_avatar bg02"><span></span></span>
                                                       <span class="content">
                                                           <strong class="title"><span class="text" style="background-color: #e0e0e0; width: 100%;">&nbsp;</span></strong>
                                                           <em class="meta" style="width: 20%; background-color: #ededed;">&nbsp;</em>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                       </span>
                                                   </a>
                                               </li>
                                               <li>
                                                   <a href="#" class="post_item">
                                                      <span class="ui_avatar bg02"><span></span></span>
                                                       <span class="content">
                                                           <strong class="title"><span class="text" style="background-color: #e0e0e0; width: 100%;">&nbsp;</span></strong>
                                                           <em class="meta" style="width: 20%; background-color: #ededed;">&nbsp;</em>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                       </span>
                                                   </a>
                                               </li>
                                               <li>
                                                   <a href="#" class="post_item">
                                                      <span class="ui_avatar bg02"><span></span></span>
                                                       <span class="content">
                                                           <strong class="title"><span class="text" style="background-color: #e0e0e0; width: 100%;">&nbsp;</span></strong>
                                                           <em class="meta" style="width: 20%; background-color: #ededed;">&nbsp;</em>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                       </span>
                                                   </a>
                                               </li>
                                               <li>
                                                   <a href="#" class="post_item">
                                                      <span class="ui_avatar bg02"><span></span></span>
                                                       <span class="content">
                                                           <strong class="title"><span class="text" style="background-color: #e0e0e0; width: 100%;">&nbsp;</span></strong>
                                                           <em class="meta" style="width: 20%; background-color: #ededed;">&nbsp;</em>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                       </span>
                                                   </a>
                                               </li>
										</ul>	
										<div id="portalMailListMore" name="BtnPortalListMore" class="btn_list_more"  style="display: none;">
											<a href="#" class="ui-link" onclick="mobile_portal_main_page_ListMore();" ><span><spring:message code="Cache.lbl_MoreView" /></span></a>
										</div>
									</div>
									<div class="ui_empty" hidden>
                                        <div class="message">
                                            <p><spring:message code="Cache.msg_NoDataList" /></p>		<!-- 조회할 목록이 없습니다. -->
                                        </div>
                                    </div>
								</div>
							</div>		
							<div class="view_panel swiper-no-swiping">
                                    <div class="ui_empty">
                                        <div class="message">
                                            <p><spring:message code="Cache.msg_clickListForShow" /></p> <!-- 좌측 목록을 클릭하시면 내용 미리보기가 가능합니다. -->
                                        </div>
                                    </div>
                                </div>
		                </div>            
		            </div>    
				</div>
				<input type="hidden" id="portal_mail_currentPage" value="1">
				<input type="hidden" id="portal_mail_endoflist" value="false">
                <c:set var="data_index" value="${data_index+1}"/>
         		</c:if>
         		<!-- 결재 tab -->
         		<c:if test = "${fn:contains(MobileHomeTab, 'A')}">
         		<input type="hidden" id="portal_approval_currentPage" value="1">
				<input type="hidden" id="portal_approval_endoflist" value="false">
                <div class="swiper-slide post-swiper portal-panel" data-hash="approval" data-index="${data_index}" data-tab="A">
	         		<div class="portal_post portal_approval portal_slide_content">
	         			<!-- post head -->
	         			<div class="post_head">
	         				<h3><spring:message code="Cache.lbl_apv_appDoc" /></h3>
                            <a href="javascript:mobile_comm_go('/approval/mobile/approval/list.do')" class="more"><span><spring:message code="Cache.lbl_MoreView" /></span></a>
	         			</div>
	         			<!-- post container -->
                        <div class="post_container">
	                        <div class="list_panel">
	                        	<div data-custom-scrollbar>
            						<div class="post_list">
               							<ul id="ulPortalApprovalList">
											<li>
                                                   <a href="#" class="post_item">
                                                      <span class="ui_avatar bg02"><span></span></span>
                                                       <span class="content">
                                                           <strong class="title"><span class="text" style="background-color: #e0e0e0; width: 100%;">&nbsp;</span></strong>
                                                           <em class="meta" style="width: 20%; background-color: #ededed;">&nbsp;</em>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                       </span>
                                                   </a>
                                               </li>
                                               <li>
                                                   <a href="#" class="post_item">
                                                      <span class="ui_avatar bg02"><span></span></span>
                                                       <span class="content">
                                                           <strong class="title"><span class="text" style="background-color: #e0e0e0; width: 100%;">&nbsp;</span></strong>
                                                           <em class="meta" style="width: 20%; background-color: #ededed;">&nbsp;</em>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                       </span>
                                                   </a>
                                               </li>
                                               <li>
                                                   <a href="#" class="post_item">
                                                      <span class="ui_avatar bg02"><span></span></span>
                                                       <span class="content">
                                                           <strong class="title"><span class="text" style="background-color: #e0e0e0; width: 100%;">&nbsp;</span></strong>
                                                           <em class="meta" style="width: 20%; background-color: #ededed;">&nbsp;</em>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                       </span>
                                                   </a>
                                               </li>
                                               <li>
                                                   <a href="#" class="post_item">
                                                      <span class="ui_avatar bg02"><span></span></span>
                                                       <span class="content">
                                                           <strong class="title"><span class="text" style="background-color: #e0e0e0; width: 100%;">&nbsp;</span></strong>
                                                           <em class="meta" style="width: 20%; background-color: #ededed;">&nbsp;</em>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                       </span>
                                                   </a>
                                               </li>
                                               <li>
                                                   <a href="#" class="post_item">
                                                      <span class="ui_avatar bg02"><span></span></span>
                                                       <span class="content">
                                                           <strong class="title"><span class="text" style="background-color: #e0e0e0; width: 100%;">&nbsp;</span></strong>
                                                           <em class="meta" style="width: 20%; background-color: #ededed;">&nbsp;</em>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                       </span>
                                                   </a>
                                               </li>
                                               <li>
                                                   <a href="#" class="post_item">
                                                      <span class="ui_avatar bg02"><span></span></span>
                                                       <span class="content">
                                                           <strong class="title"><span class="text" style="background-color: #e0e0e0; width: 100%;">&nbsp;</span></strong>
                                                           <em class="meta" style="width: 20%; background-color: #ededed;">&nbsp;</em>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                       </span>
                                                   </a>
                                               </li>
                                               <li>
                                                   <a href="#" class="post_item">
                                                      <span class="ui_avatar bg02"><span></span></span>
                                                       <span class="content">
                                                           <strong class="title"><span class="text" style="background-color: #e0e0e0; width: 100%;">&nbsp;</span></strong>
                                                           <em class="meta" style="width: 20%; background-color: #ededed;">&nbsp;</em>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                       </span>
                                                   </a>
                                               </li>
                                               <li>
                                                   <a href="#" class="post_item">
                                                      <span class="ui_avatar bg02"><span></span></span>
                                                       <span class="content">
                                                           <strong class="title"><span class="text" style="background-color: #e0e0e0; width: 100%;">&nbsp;</span></strong>
                                                           <em class="meta" style="width: 20%; background-color: #ededed;">&nbsp;</em>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                       </span>
                                                   </a>
                                               </li>
                                               <li>
                                                   <a href="#" class="post_item">
                                                      <span class="ui_avatar bg02"><span></span></span>
                                                       <span class="content">
                                                           <strong class="title"><span class="text" style="background-color: #e0e0e0; width: 100%;">&nbsp;</span></strong>
                                                           <em class="meta" style="width: 20%; background-color: #ededed;">&nbsp;</em>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                       </span>
                                                   </a>
                                               </li>
                                               <li>
                                                   <a href="#" class="post_item">
                                                      <span class="ui_avatar bg02"><span></span></span>
                                                       <span class="content">
                                                           <strong class="title"><span class="text" style="background-color: #e0e0e0; width: 100%;">&nbsp;</span></strong>
                                                           <em class="meta" style="width: 20%; background-color: #ededed;">&nbsp;</em>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                       </span>
                                                   </a>
                                               </li>
            							</ul>
            							<div id="portalApprovalListMore" name="BtnPortalListMore" class="btn_list_more" style="display: none;">
											<a href="#" class="ui-link" onclick="mobile_portal_main_page_ListMore()"><span><spring:message code="Cache.lbl_MoreView" /></span></a>
										</div>
                 					</div>
                 					<div class="ui_empty" hidden>
		                        		<div class="message">
		                        			<p><spring:message code="Cache.msg_NoDataList" /></p>		<!-- 조회할 목록이 없습니다. -->
		                        		</div>
		                        	</div>
	                        	</div>
	                        	
	                        </div>
	                        <div class="view_panel swiper-no-swiping">
	                        	<div class="ui_empty">
	                        		<div class="message">
	                        			<p><spring:message code="Cache.msg_clickListForShow" /></p> <!-- 좌측 목록을 클릭하시면 내용 미리보기가 가능합니다. -->
	                        		</div>
	                        	</div>
	                        </div>
                        </div>
                    </div>    
                </div>
                <c:set var="data_index" value="${data_index+1}"/>
                </c:if>
         		<!-- 게시 tab -->
         		<c:if test = "${fn:contains(MobileHomeTab, 'B')}">
         		<input type="hidden" id="portal_board_currentPage" value="1">
				<input type="hidden" id="portal_board_endoflist" value="false">
                <div class="swiper-slide post-swiper portal-panel" data-hash="board" data-index="${data_index}" data-tab="B">
	         		<div class="portal_post portal_board portal_slide_content">
                           <div class="post_head">
                               <h3><spring:message code="Cache.lbl_IncludeRecentReg" /></h3>
                               <a href="javascript:mobile_comm_go('/groupware/mobile/board/list.do?menucode=BoardMain&boardtype=Total')" class="more"><span><spring:message code="Cache.lbl_MoreView" /></span></a>
                           </div>
                           <div class="post_container">
                               <div class="list_panel">
                                   <div data-custom-scrollbar data-target='board'>
                                       <div class="post_list">
                                           <ul id="ulPortalBoardList">
                                               <li>
                                                   <a href="#" class="post_item">
                                                      <span class="ui_avatar bg02"><span></span></span>
                                                       <span class="content">
                                                           <strong class="title"><span class="text" style="background-color: #e0e0e0; width: 100%;">&nbsp;</span></strong>
                                                           <em class="meta" style="width: 20%; background-color: #ededed;">&nbsp;</em>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                       </span>
                                                   </a>
                                               </li>
                                               <li>
                                                   <a href="#" class="post_item">
                                                      <span class="ui_avatar bg02"><span></span></span>
                                                       <span class="content">
                                                           <strong class="title"><span class="text" style="background-color: #e0e0e0; width: 100%;">&nbsp;</span></strong>
                                                           <em class="meta" style="width: 20%; background-color: #ededed;">&nbsp;</em>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                       </span>
                                                   </a>
                                               </li>
                                               <li>
                                                   <a href="#" class="post_item">
                                                      <span class="ui_avatar bg02"><span></span></span>
                                                       <span class="content">
                                                           <strong class="title"><span class="text" style="background-color: #e0e0e0; width: 100%;">&nbsp;</span></strong>
                                                           <em class="meta" style="width: 20%; background-color: #ededed;">&nbsp;</em>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                       </span>
                                                   </a>
                                               </li>
                                               <li>
                                                   <a href="#" class="post_item">
                                                      <span class="ui_avatar bg02"><span></span></span>
                                                       <span class="content">
                                                           <strong class="title"><span class="text" style="background-color: #e0e0e0; width: 100%;">&nbsp;</span></strong>
                                                           <em class="meta" style="width: 20%; background-color: #ededed;">&nbsp;</em>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                       </span>
                                                   </a>
                                               </li>
                                               <li>
                                                   <a href="#" class="post_item">
                                                      <span class="ui_avatar bg02"><span></span></span>
                                                       <span class="content">
                                                           <strong class="title"><span class="text" style="background-color: #e0e0e0; width: 100%;">&nbsp;</span></strong>
                                                           <em class="meta" style="width: 20%; background-color: #ededed;">&nbsp;</em>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                       </span>
                                                   </a>
                                               </li>
                                               <li>
                                                   <a href="#" class="post_item">
                                                      <span class="ui_avatar bg02"><span></span></span>
                                                       <span class="content">
                                                           <strong class="title"><span class="text" style="background-color: #e0e0e0; width: 100%;">&nbsp;</span></strong>
                                                           <em class="meta" style="width: 20%; background-color: #ededed;">&nbsp;</em>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                       </span>
                                                   </a>
                                               </li>
                                               <li>
                                                   <a href="#" class="post_item">
                                                      <span class="ui_avatar bg02"><span></span></span>
                                                       <span class="content">
                                                           <strong class="title"><span class="text" style="background-color: #e0e0e0; width: 100%;">&nbsp;</span></strong>
                                                           <em class="meta" style="width: 20%; background-color: #ededed;">&nbsp;</em>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                       </span>
                                                   </a>
                                               </li>
                                               <li>
                                                   <a href="#" class="post_item">
                                                      <span class="ui_avatar bg02"><span></span></span>
                                                       <span class="content">
                                                           <strong class="title"><span class="text" style="background-color: #e0e0e0; width: 100%;">&nbsp;</span></strong>
                                                           <em class="meta" style="width: 20%; background-color: #ededed;">&nbsp;</em>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                       </span>
                                                   </a>
                                               </li>
                                               <li>
                                                   <a href="#" class="post_item">
                                                      <span class="ui_avatar bg02"><span></span></span>
                                                       <span class="content">
                                                           <strong class="title"><span class="text" style="background-color: #e0e0e0; width: 100%;">&nbsp;</span></strong>
                                                           <em class="meta" style="width: 20%; background-color: #ededed;">&nbsp;</em>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                       </span>
                                                   </a>
                                               </li>
                                               <li>
                                                   <a href="#" class="post_item">
                                                      <span class="ui_avatar bg02"><span></span></span>
                                                       <span class="content">
                                                           <strong class="title"><span class="text" style="background-color: #e0e0e0; width: 100%;">&nbsp;</span></strong>
                                                           <em class="meta" style="width: 20%; background-color: #ededed;">&nbsp;</em>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                           <span class="meta" style="width: 40%; background-color: #ededed;">&nbsp;</span>
                                                       </span>
                                                   </a>
                                               </li>
                                           </ul>
											<div id="portalBoardListMore" name="BtnPortalListMore" class="btn_list_more" style="display: none;">
												<a href="#" class="ui-link" onclick="mobile_portal_main_page_ListMore()" ><span><spring:message code="Cache.lbl_MoreView" /></span></a>
											</div>
                                       </div>
										<div class="ui_empty" hidden>
											<div class="message">
												<p><spring:message code="Cache.msg_NoDataList" /></p>		<!-- 조회할 목록이 없습니다. -->
											</div>
										</div>
									</div>
								</div>
								<div class="view_panel swiper-no-swiping">
									<div class="ui_empty">
										<div class="message">
											<p><spring:message code="Cache.msg_clickListForShow" /></p> <!-- 좌측 목록을 클릭하시면 내용 미리보기가 가능합니다. -->
										</div>
									</div>
								</div>
							</div>
						</div>
         			</div>
                <c:set var="data_index" value="${data_index+1}"/>
   				</c:if>
   			</div>
   		</div>	
   </div>
			
	<!-- 음성인식 시작 -->
	<div id="divportalVoiceListener" class="ui_voice_toggle used" style="display: none;">
        <button type="button" onclick="mobile_portalVoiceCall();"><span>음성검색</span></button>
	</div>
	<!-- 음성인식 끝 -->
	
	<!-- 음성가이드 팝업 시작 -->
	<div id="divVoiceGuidePop" class="mobile_popup_wrap" style="display: none;">
		<div class="voice_search_wrap" style="height: 260px;">
			<a href="#" onclick="mobile_portalVoiceGuideClose()" class="btn_voice_cancel"><span>닫기</span></a>
			<p class="voice_pop_title">음성지원 명령</p>
			<div class="voice_pop_cont">
				<ul class="voice_pop_cont_list">
					<li>사용자 OOO 검색</li>
					<li>받은 메일 보여줘</li>
					<li>안읽은 메일 보여줘</li>
					<li>결재 미결함 보여줘</li>
				</ul>
			</div>
			<div class="write_info_wrap" style="display: none;">
				<p class="write_info">음성인식 버튼을 길게 눌러 기능을 활성 또는 비활성화 할 수 있습니다.</p>
			</div>
			<p style="display: none;">
				<div class="voice_input_check" style="display: none;">
					<input type="checkbox" id="chkVoiceGuideDisplay" class="voice_check">
					<label for="chkVoiceGuideDisplay" id="chkVoiceGuideDisplayLib">더이상 보지 않기</label>
				</div>
			</p>
		</div>
	</div>
	<!-- 음성가이드 팝업 끝 -->
		
	<!-- 팝업 시작 -->
	<div id="divViceMulti" class="mobile_popup_wrap" style="display: none;">
		<div class="voice_search_wrap">
			<a href="javascript:$('#divViceMulti').hide()" class="btn_voice_cancel"><span>닫기</span></a>
			<div class="voice_search_list_scroll">
				<ul class="voice_search_list" id='ulSearchText'></ul>
			</div>
		</div>
	</div>
	<!-- 팝업 끝 -->
	
	<script type="text/template" id="tempMailLi">
	<li>
		<a href="{url}" class="post_item {read}">
			<span class="ui_avatar {bgColor}">{profileImage}</span>
			<span class="content">
				<strong class="title">
					{attahcedFile}
					<span class="text">{title}</span>
				</strong>
				<em class="meta">{folderName}</em>
				<span class="meta">{registerName}</span>
				<span class="meta">{registDate}</span>
			</span>
		</a>
	</li>
	</script>
	
	<script type="text/template" id="tempApprovalLi">
	<li>
		<a href="{url}" class="post_item ui-link {read}">
			<span class="ui_avatar {bgColor}">{profileImage}</span>
			<span class="content">
				<strong class="title">
					{file} {emer} {sec} 
					<span class="text">{subject}</span>
				</strong>
				<em class="meta">{subKind}</em>
				<span class="meta">{initiatorName}</span>
				<span class="meta">{registBefore}</span>
				<span class="meta">{formName}</span>
			</span>
		</a>
	</li>
	</script>
	
	<script type="text/template" id="tempBoardLi">
	<li>
		<a href="{url}" class="post_item {read}">
			<span class="ui_avatar {bgColor}">{profileImage}</span>
			<span class="content">
				<strong class="title">
					{attahcedFile}
					<span class="text">{title}</span>
				</strong>
				<em class="meta">{folderName}</em>
				<span class="meta">{registerName}</span>
				<span class="meta">{registDate}</span>
			</span>
		</a>
	</li>
	</script>

	<script type="text/template" id="setting_drawer">
    <div class="drawer_header">
        <div class="setting_profile">
            <div class="ui_avatar"><img src="/covicore/common/photo/photo.do?img=<%=SessionCommonHelper.getSession("PhotoPath")%>" alt="아바타" onerror="mobile_comm_imageerror(this, true)"></div>
            <div class="info">
              <strong><%=SessionCommonHelper.getSession("UR_Name")%> <%=SessionCommonHelper.getSession("UR_JobPositionName")%></strong>
              <em><%=SessionCommonHelper.getSession("DEPTNAME")%></em>
            </div>
        </div>
    </div>
    <div class="drawer_content design_setting_content">
        <div class="setting_grid"  style="display:none">
            <button type="button" class="grid_title"><span><%=DicHelper.getDic("PT_Style")%></span></button>
            <div class="grid_row"  id="mode">
                <label class="ui_checkbox"><input type="radio" name="mode" value="light" <%=(SessionCommonHelper.getSessionMapKey("PortalOption", "mbMode").equals("light")?"checked":"")%> onclick="mobile_portal_setMyPortal('mbMode',this)"><i></i><span><%=DicHelper.getDic("PT_StyleLight")%></span></label>
                <label class="ui_checkbox"><input type="radio" name="mode" value="dark"  <%=(SessionCommonHelper.getSessionMapKey("PortalOption", "mbMode").equals("dark")?"checked":"")%> onclick="mobile_portal_setMyPortal('mbMode',this)"><i></i><span><%=DicHelper.getDic("PT_StyleDark")%></span></label>
				<%
				String useTeamsAddIn = "N";
				String userAgent = request.getHeader("User-Agent");
				String pIsTeamsAddIn = request.getParameter("teamsaddin");
			    if ((userAgent != null && userAgent.toLowerCase().indexOf("teams") > -1) || (pIsTeamsAddIn != null && pIsTeamsAddIn.toUpperCase().equals("Y"))) {
			    	useTeamsAddIn = "Y";
			    %>
                <label class="ui_checkbox"><input type="radio" name="mode" value="auto"  <%=(SessionCommonHelper.getSessionMapKey("PortalOption", "mbMode").equals("auto")?"checked":"")%> onclick="mobile_portal_setMyPortal('mbMode',this)"><i></i><span><%=DicHelper.getDic("PT_StyleAuto")%></span></label>
				<%}%>
            </div>
        </div>
		<%
		if (!"Y".equalsIgnoreCase(useTeamsAddIn)) {
		%>	
			<c:if test="${fn:length(themeColor)>1}">
			<div class='setting_grid' >
				<button type='button' class='grid_title' data-icon='language'><span><%=DicHelper.getDic("lbl_ChangeTheme")%></span></button>
				<div class="grid_selector_list theme" id="theme">
				<c:forEach var="list"  items="${themeColor}" varStatus="status">
	        		<label class='selector'  data-color="${list.Code}"><input type="radio" name="theme"   ${list.Code eq myPortalOption.mbTheme?"checked":""} onclick="mobile_portal_setMyPortal('mbTheme',this)" value="${list.Code}"><i></i><span>${covi:getDicInfo(list.MultiCodeName,myBaseData.lang)}</span></label>
				</c:forEach>
         		</div>
     		</div>
			</c:if>
		<%
		}
		%>
        <div class="setting_grid" aria-expanded='false'>
            <button type="button" class="grid_title"><span><%=DicHelper.getDic("PT_PortalBackground")%></span></button>
            <div class="grid_switch" id="dim">
                <span class="switch_label"><%=DicHelper.getDic("PT_PortalDim")%></span>
                <label class="ui_switch"><input type="checkbox" ${myPortalOption.mbDim == "Y"?"checked":""} onclick="mobile_portal_setMyPortal('mbDim',this, true)" value="Y"><i></i></label>
            </div>
			<c:if test="${fn:length(portalBg)>1}"> 
            <div class="grid_sub_head">
                <h4 class="grid_sub_title"><%=DicHelper.getDic("CPMail_Image")%></h4>
            </div>
            <div class="grid_selector_list image"  id="portalBg">
                <label class="image_upload"><input type="file"  accept=".jpg, .jpeg, .png, .gif" onchange="mobile_portal_loadFile()"><span><%=DicHelper.getDic("btn_Upload")%></span></label>
			  	<c:if test="${!empty myPortalOption.portalBgPath and myPortalOption.portalBgPath ne ''}">
	        		<label class='selector custom-img' style="background-image:url('/covicore/common/photo/photo.do?img=${myPortalOption.portalBgPath}')">
						<input type="radio" name="background"  ${'image-custom' eq myPortalOption.mbPortalBg?"checked":""} value="image-custom" onclick="mobile_portal_setMyPortal('mbPortalBg',this)" ><i></i>
						<button type="button" class="selector_delete" onclick="mobile_portal_deleteFile()"><span>삭제</span></button>	
					</label>
				</c:if>
				<c:forEach var="list"  items="${portalBg}" varStatus="status">
	        		<label class='selector' data-thumbnail="${list.Reserved1}"><input type="radio" name="background"  ${list.Code eq myPortalOption.mbPortalBg?"checked":""} onclick="mobile_portal_setMyPortal('mbPortalBg',this)" value="${list.Code}"><i></i></label>
				</c:forEach>
            </div>
			<h4 class="grid_sub_title"<%=DicHelper.getDic("PT_PortalColor")%></h4>
            <div class="grid_selector_list color">
				<c:forEach var="list"  items="${portalColor}" varStatus="status">
	        		<label class='selector' data-color="${list.Code}"><input type="radio" name="background"  ${list.Code eq myPortalOption.mbPortalBg?"checked":""} onclick="mobile_portal_setMyPortal('mbPortalBg',this)" value="${list.Code}"><i></i></label>
				</c:forEach>
            </div>
			</c:if>        
        </div>
		<c:if test="${fn:length(portalColor)>1}"> 
        <div class="setting_grid" aria-expanded='false'>
            <button type="button" class="grid_title"><span><%=DicHelper.getDic("PT_PortalText")%></span></button>
            <div class="grid_row bg" id="portalText">
                <label class="ui_checkbox"><input type="radio" name="portal_text_color" ${myPortalOption.mbPortalText == "white"?"checked":""}  value="white"  onclick="mobile_portal_setMyPortal('mbPortalText',this)" ><i></i><span>White</span></label>
                <label class="ui_checkbox"><input type="radio" name="portal_text_color" ${myPortalOption.mbPortalText == "black"?"checked":""}   value="black"  onclick="mobile_portal_setMyPortal('mbPortalText',this)" ><i></i><span>Black</span></label>
            </div>
        </div>
		</c:if>        
		<c:if test = "${fn:contains(MobileHomeTab, 'P')}"> <!--포탈 포함이면-->
        <div class="setting_grid"><!--위젯-->
            <button type="button" class="grid_title"><span><%=DicHelper.getDic("PT_PortalWidget")%></span></button>
            <div class="grid_check_list">
                <ul id="widgetSorting" class="sortable">
				<c:forEach var="list"  items="${myAllWidget}" varStatus="status">
                  <li>
						<label class="ui_checkbox"><input type="checkbox" ${(myWidgetCnt eq '0' and (list.Reserved1 eq 'FIX' or list.Reserved1 eq 'DEF' ) or list.IsMy eq 'Y') ?"checked":""}  ${list.Reserved1 eq 'FIX' ?" disabled":""} value="${list.WebpartID}" onclick="mobile_portal_saveMyContents('widget',this)"><i></i><span>${list.DisplayName}</span></label>
                      <div class="handle"><span>위치이동</span></div>
				  </li>
				</c:forEach>
                </ul>
            </div>
        </div>
		</c:if>
		<c:if test = "${fn:contains(MobileHomeTab, 'C')}"> <!--마이컨텐츠 포함이면-->
        <div class="setting_grid" aria-expanded='false'>
            <button type="button" class="grid_title"><span><%=DicHelper.getDic("lbl_Content")%></span></button>
            <div class="grid_check_list">
                <ul id="contentsSorting" class="sortable">
					<c:forEach var="list"  items="${myAllContents}" varStatus="status">
                	  <li>
						<label class="ui_checkbox"><input type="checkbox" ${(myContentsCnt eq '0' and (list.Reserved1 eq 'FIX' or list.Reserved1 eq 'DEF' ) or list.IsMy eq 'Y') ?"checked":""}  ${list.Reserved1 eq 'FIX' ?" disabled":""} value="${list.WebpartID}"  onclick="mobile_portal_saveMyContents('contents',this)"><i></i><span>${list.DisplayName}</span></label>
                      <div class="handle"><span>위치이동</span></div>
				  	</li>
					</c:forEach>
                </ul>
            </div>
      </div>
	  </c:if>
    </div>
	  <div class="drawer_footer">
        <button type="button" class="ui_button" id="ptClose"><span><%=DicHelper.getDic("btn_Cancel")%></span></button>
        <button type="button" class="ui_button primary "  onclick="mobile_portal_savePortalWebpart(true)"><span><%=DicHelper.getDic("lbl_apply")%></span></button>
     </div>
</script>

</div>
</div>
