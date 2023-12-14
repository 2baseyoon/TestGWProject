<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ page import="org.springframework.web.context.support.WebApplicationContextUtils"%>
<%@ page import="egovframework.coviframework.util.DicHelper"%>
<%@ page import="egovframework.baseframework.data.CoviList"%>
<%@ page import="egovframework.baseframework.data.CoviMap"%>
<%@ page import="egovframework.covision.coviflow.user.service.ApprovalListSvc"%>
<%@ page import="org.springframework.web.context.WebApplicationContext"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil"%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
	
	ServletContext servletContext = getServletContext();
	WebApplicationContext waContext = WebApplicationContextUtils.getRequiredWebApplicationContext(servletContext);
	ApprovalListSvc service = (ApprovalListSvc) waContext.getBean("approvalListService");
	
	
	CoviMap params = new CoviMap();
	params.put("Type", "SECTION"); // 섹션
	CoviList sectionList = service.selectHomeSectionSort(params);
	if(sectionList == null || sectionList.size() != 3){
		// when not found sort data
		sectionList = new CoviList();
		CoviMap info1 = new CoviMap();
		info1.put("SectionKey", "widget_timeline");
		sectionList.add(info1);
		CoviMap info2 = new CoviMap();
		info2.put("SectionKey", "widget_status");
		sectionList.add(info2);
		CoviMap info3 = new CoviMap();
		info3.put("SectionKey", "widget_favorites");
		sectionList.add(info3);
	}
	
	params.put("Type", "LISTTYPE");// 결재함
	CoviList tabList = service.selectHomeSectionSort(params);
	if(tabList == null || tabList.size() != 3){
		// when not found sort data
		tabList = new CoviList();
		CoviMap info1 = new CoviMap();
		info1.put("SectionKey", "APPROVAL");
		tabList.add(info1);
		CoviMap info2 = new CoviMap();
		info2.put("SectionKey", "REF");
		tabList.add(info2);
		CoviMap info3 = new CoviMap();
		info3.put("SectionKey", "CIRCULAR");
		tabList.add(info3);
	}
%>
<script type="text/javascript" src="/approval/resources/script/user/approvestat.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/approval/resources/script/user/common/ApprovalUserCommon.js<%=resourceVersion%>"></script>
<script type="text/javascript" src="/approval/resources/script/user/ApprovalListCommon.js<%=resourceVersion%>"></script>
<jsp:include page="/WEB-INF/views/user/approval/UserApprovalGuide.jsp"></jsp:include>

<!-- 본문 시작 -->
<div class="content"><!-- tab 영역 내부에서 position absolute 적용되어야 스크롤 초기화가 동작함. -->
<div class="ui_main ui_dashboard ui_dashboard_approval">
    <div class="ui_head">
        <h3 class="head_title title"><spring:message code="Cache.lbl_apv_dashboard"/></h3><!-- 전자결재 홈 -->
        <div class="tip">
            <p id="delayMsg">&nbsp;</p>
        </div>
    </div>
    <div class="ui_content">
        <div data-custom-scrollbar>
            <div class="dashboard_message">
                <div class="ui_alert alert_outlined" data-type="info" role="alert">
                    <div class="alert_message">
                        <p><spring:message code="Cache.msg_apv_dashboard_desc"/></p><!-- 설명메시지 -->
                    </div>
                </div>
            </div>
            <div class="dashboard_list">
            	<%
            	for(int i = 0; i < sectionList.size(); i++){
            		CoviMap sectionInfo = sectionList.getJSONObject(i);
            		if("widget_timeline".equals(sectionInfo.getString("SectionKey"))){
            			
            	%>
                <div class="dashboard_card widget_timeline" type="widget_timeline">
                    <div class="card_root">
                        <div class="card_head">
                            <div class="title"><spring:message code="Cache.lbl_apv_timeline"/></div><!-- 타임라인 -->
                            <div class="action">
                                <span class="card_move_handle"><span> </span></span>
                            </div>
                        </div>
                        <div class="card_content">
                            <div data-custom-scrollbar>
                                <div class="timeline_list" id="timeLine">
                                </div>
                            </div>
                        </div>
                        <div class="card_foot">
                            <button class="ui_icon_button card_content_toggle" onclick="toggleContents(this);"><span>열기/닫기</span></button>
                        </div>
                    </div>
                </div>
                <%
            		}// if
            		else if("widget_status".equals(sectionInfo.getString("SectionKey"))){
                %>
                <div class="dashboard_card widget_status" type="widget_status">
                    <div class="card_root">
                        <div class="card_head">
                            <div class="title"><spring:message code="Cache.lbl_apv_status"/></div><!-- 결재현황 -->
                            <div class="action">
                                <span class="card_move_handle"><span></span></span>
                                <button type="button" class="card_more" onclick="approvalHome.goApprovalMenu();"><span> </span></button>
                            </div>
                        </div>
                        <div class="tab_menu" role="tablist" id="approval_list_tab">
                        	<!-- dynamic sorting -->
                           	<%
                           	String selected = "false";
                           	for(int k = 0; k < tabList.size(); k++){
                           		selected = "false";
                           		
                           		CoviMap info = tabList.getJSONObject(k);
                           		String name = "";
                           		String emId = "";
                           		String ltype = info.getString("SectionKey");
                    			if(k == 0){selected = "true";}
                    			if("APPROVAL".equals(info.getString("SectionKey"))) {
                    				name = DicHelper.getDic("lbl_apv_unreadApprovalCnt");// 읽지않은 미결문서
                    				emId = "cnt_unread_approval";
                    			}else if("REF".equals(info.getString("SectionKey"))) {
                    				name = DicHelper.getDic("lbl_apv_unreadRefCnt");// 읽지않은 참조문서
                    				emId = "cnt_unread_reference";
                    			}else if("CIRCULAR".equals(info.getString("SectionKey"))) {
                    				name = DicHelper.getDic("lbl_apv_unreadCircularCnt");// 읽지않은 회람문서
                    				emId = "cnt_unread_circular";
                    			}
                           	%>
                           	<button type="button" role="tab" class="tab" aria-selected="<%=selected %>" lType="<%=ltype%>"><span><%=name %></span><em id="<%=emId%>">0</em></button>
                           	
                           	<%
                           	}
                           	%>
                        </div>
                        <div class="card_content">
                            <div data-custom-scrollbar id="approval_list">
                                <div class="status_list">
                                    <ul id="approval_list_ul">
                                    	<!-- 결재문서 목록 영역 -->
                                    </ul>
                                </div>
                            </div>
                            <div class="ui_empty" id="approval_list_empty" hidden><p><spring:message code="Cache.msg_NoDataList"/></p></div>
                        </div>
                        <div class="card_foot">
                            <button class="ui_icon_button card_content_toggle" onclick="toggleContents(this);"><span>열기/닫기</span></button>
                        </div>
                    </div>
                </div>
                <%
            		}// if
            		else if("widget_favorites".equals(sectionInfo.getString("SectionKey"))){
                %>
                <div class="dashboard_card widget_favorites" type="widget_favorites">
                    <div class="card_root">
                        <div class="card_head">
                            <div class="title"><spring:message code="Cache.lbl_Favorite"/></div><!-- 즐겨찾기 -->
                            <div class="action">
                                <span class="card_move_handle"><span>이동</span></span>
                                <button type="button" class="card_more" onclick="CoviMenu_GetContent('/approval/layout/approval_FormList.do?CLSYS=approval&CLMD=user&CLBIZ=Approval');"><span>더보기</span></button>
                            </div>
                        </div>
                        <div class="card_content">
                            <div data-custom-scrollbar>
                                <div class="favorites_list" id="FavoriteFormList">
                                </div>
                            </div>
                        </div>
                        <div class="card_foot">
                            <button class="ui_icon_button card_content_toggle" onclick="toggleContents(this);"><span>열기/닫기</span></button>
                        </div>
                    </div>
                </div>
                <%
            		}//if
            	}//for
                %>
            </div>
            <div class="dashboard_action">
                <button type="button" class="ui_button" id="cancelDashboardEdit"><span><spring:message code="Cache.btn_Cancel"/></span></button><!-- 취소 -->
                <button type="button" class="ui_button primary" onclick="sortHomeSectionTab();"><span><spring:message code="Cache.btn_Apply"/></span></button><!-- 적용 -->
            </div>
        </div>
    </div>
    <button type="button" class="ui_floating_action_button" data-icon="setting" id="activateDashboardEdit" data-tooltip-title="<spring:message code='Cache.lbl_dashboardSetting'/>" data-tooltip-position="left"><span>설정</span></button>
</div>
</div>
<script type="text/javascript">
   	var sessionObj = null; //전체호출
   	//initHome(); 위치 이동.
    
   	function ApprovalHome() {
   		this.initHome =	function() {
   			//$("header").empty();
   			init();
   		};
   		
   		function init(){
   			sessionObj = Common.getSession(); //전체호출
   			
   			setApprovalDelayMsg();
   			
   			// 섹션별로 로딩, 탭변경시 Reload.
   			var defaultTabId = $('.ui_dashboard_approval .tab_menu .tab[aria-selected="true"]').attr("lType");
   			setListData(defaultTabId);
   			
   			// Tiles 로 로딩시 자동으로 스크롤스타일이 적용되지 않아 수동 실행.
   			var $scroll_area = $("[data-custom-scrollbar]", ".dashboard_list").not(".mCustomScrollbar");
   			$.each($scroll_area, function(){
   			    new SimpleBar(this, {autoHide: false});
   			});
   			
   			setAlarmList();	// 나의 결재 현황
   			setFavoriteUserForms(); // 즐려찾는 양식목록 조회
   			
   			$('.ui_dashboard_approval .tab_menu .tab', document).on('click', function () {
   			    setListData($(this).attr("lType"));
   			});
   		    
   			// 문서목록 탭 드래그&드랍
   		    this.$approvalDashboardTab = document.querySelector('.ui_dashboard_approval .tab_menu');
   		    if ($approvalDashboardTab) {
   		        Sortable.create($approvalDashboardTab, {
   		            forceFallback: true,
   		            delay: 250,
   		            animation: 150,
   		            onUpdate: function (evt){
   		            	sortApprovalListTab();
   		            }
   		        });
   		    }
   		 	// 즐겨찾기 양식목록 드래그&드랍
   		    this.$approvalDashboardFavorites = document.querySelector('.ui_dashboard_approval .favorites_list');
   		    if ($approvalDashboardFavorites) {
   		        Sortable.create($approvalDashboardFavorites, {
   		            forceFallback: true,
   		            handle: '.move',
   		            animation: 150,
   		            onUpdate: function (evt){
   		            	sortFormList();
   		            }
   		        });
   		    }
   		    
   		    this.$apvDashboardList = document.querySelector('.ui_dashboard .dashboard_list');
   		    this.$apvDashboardGroup = document.querySelectorAll('.ui_dashboard .dashboard_list .dashboard_group');
   		    // 대시보드 위치 이동
   		    if ($apvDashboardList) {
   		        this.dashboardSortableList = Sortable.create($apvDashboardList, {
   		            forceFallback: true,
   		            animation: 150
   		        });
   		    }
   		    // 대시보드 그룹 내부 위치 이동
   		    if ($apvDashboardGroup.length > 0) {
   		        for (let i = 0; i < $apvDashboardGroup.length; i++) {
   		            this.dashboardSortableGroup = Sortable.create($apvDashboardGroup[i], {
   		                forceFallback: true,
   		                handle: '.card_move_handle',
   		                animation: 150
   		            });
   		        }
   		    }
   		    if ($apvDashboardList) dashboardSortableList.option('disabled', true);
   		    if ($apvDashboardGroup.length > 0) dashboardSortableGroup.option('disabled', true);

   		    // 대시보드 편집모드 활성화
   		    $('#activateDashboardEdit', document).on('click', function () {
   		    	approvalHome.toggleDashBoard(false);
   		    });

   		    // 대시보드 편집모드 취소
   		    $('#cancelDashboardEdit', document).on('click', function () {
   				location.reload();
   		    });
   		};
   		
   		this.toggleDashBoard = function(disableDnD){
   			if(disableDnD === true){
   				$('.ui_dashboard').removeClass('dashboard_editing');	
   			}else{
   				$('.ui_dashboard').addClass('dashboard_editing');
   			}
	        if ($apvDashboardList) dashboardSortableList.option('disabled', disableDnD);
	        if ($apvDashboardGroup.length > 0) dashboardSortableGroup.option('disabled', disableDnD);
   		};
   		
   		this.goApprovalMenu = function(){
   			if("APPROVAL" == $(".tab[aria-selected=true]", "#approval_list_tab").attr("ltype")){
   				// 미결함
	   			CoviMenu_GetContent('/approval/layout/approval_ApprovalList.do?CLSYS=approval&CLMD=user&CLBIZ=Approval&mode=Approval');
   			}else{
   				// 참조회람함
	   			CoviMenu_GetContent('/approval/layout/approval_ApprovalList.do?CLSYS=approval&CLMD=user&CLBIZ=Approval&mode=TCInfo');
   			}
   		}
   	}

	// 나의 결재 현황 ( Timeline )
	function setAlarmList() {
		$.ajax({
			url:"/approval/legacy/getAlarmList.do",
			data: {
				"businessData1":"APPROVAL"
			},
			type:"post",
			success:function (data) {
				$("#timeLine").empty();
				var html = "";
				var btimeLineEmpty = false;
				if (typeof(data.list) != "undefined") {
					var nowDate = $.datepicker.formatDate('yy/m/d',  new Date());
					var len = data.list.length;
					
					if (len > 0) {
	 					$.each(data.list, function(i, v) {
	  						$.each(v, function(i, v) {
	  							//html += "<li class='myDD'>";
	  							if (nowDate == i) {
	  								html += "<div class='timeline_date'><span>" + "TODAY" + "</span></div>";
	  								html += "<ul>";
	  							} else {
	  								var sTitle;
	  								if(sessionObj["lang"].toUpperCase() == "KO"){
	  									sTitle = new Date(i).format("yyyy년 M월 d일 E");
	  								}else{
	  									sTitle =  new Date(i).format("yyyy.MM.dd");
	  								}
	  								html += "<div class='timeline_date'><span>" +sTitle + "</span></div>";
	  								html += "<ul>";
	  							}
	  							var tableClass = "";
	  							var spanClass = "";
	  							var spanText = "";
	  							$.each(v, function(i, v) {
	  								switch (v.MessageType) {
		  								case "COMMENT" : tableClass = "1"; spanClass = "bgComm"; spanText = "<spring:message code='Cache.lbl_comment'/> "; break; // 의견
		  								case "UPD_CONTEXT" : tableClass = "2"; spanText = "<spring:message code='Cache.lbl_approval_editContent'/> "; break;    // 내용 편집
		  								case "UPD_APVLINE" : tableClass = "3"; spanText = "<spring:message code='Cache.lbl_approval_editLine'/> "; break;		// 결재선 편집
		  								case "UPD_ATTACH" : tableClass = "4"; spanText = "<spring:message code='Cache.lbl_approval_editFile'/> "; break;	// 첨부파일 편집
		  								case "APPROVAL" : case "CHARGE" : tableClass = "5"; spanText = "<spring:message code='Cache.lbl_approval_approvalApproval'/> "; break;		// 결재 도착
		  								case "COMPLETE" : tableClass = "6"; spanText = "<spring:message code='Cache.lbl_Completed'/>"; break;	// 완료
		  								case "REJECT" : tableClass = "7"; spanText = "<spring:message code='Cache.lbl_apv_reject'/>"; break;	// 반려
		  								case "CCINFO" : tableClass = "8"; spanText = "<spring:message code='Cache.lbl_apv_cc'/> "; break;	// 참조
		  								case "CIRCULATION" : tableClass = "9"; spanText = "<spring:message code='Cache.btn_apv_Circulate'/> "; break;	// 회람
		  								case "HOLD" : tableClass = "10"; spanText = "<spring:message code='Cache.lbl_apv_hold'/>"; break;	// 보류
		  								case "WITHDRAW" : tableClass = "11"; spanText = "<spring:message code='Cache.lbl_Withdraw'/> "; break;	// 회수
		  								case "ABORT" : tableClass = "12"; spanText = "<spring:message code='Cache.btn_apv_draftabort'/> "; break;	//기안 취소
		  								case "APPROVECANCEL" : tableClass = "13"; spanText = "<spring:message code='Cache.lbl_CancelApproval'/> "; break;	// 승인 취소
		  								case "REDRAFT" : tableClass = "14"; spanText = "<spring:message code='Cache.lbl_apv_receive'/> "; break;	// 수신 
		  								case "CHARGEJOB" : tableClass = "15"; spanText = "<spring:message code='Cache.lbl_Role'/> "; break;	// 담당업무
		  								case "CONSULTATION" : tableClass = "16"; spanText = "<spring:message code='Cache.lbl_apv_consultation'/> "; break;		// 검토
		  								case "CONSULTATIONCOMPLETE" : tableClass = "16"; spanText = "<spring:message code='Cache.lbl_apv_consultation'/> <spring:message code='Cache.lbl_Completed'/>"; break;		// 검토 완료
		  								case "CONSULTATIONCANCEL" : tableClass = "17"; spanText = "<spring:message code='Cache.lbl_apv_consultationCancel'/>"; break;		// 검토 취소
	  								}
	  								
	  								html += "<li>";
	  								if(v.State == "546") { // 회수, 기안취소된 문서는 양식본문을 확인할 수 없어 경고창 띄움
	  									html += "<a href='#' class='timeline_item' data-type='"+ tableClass +"' onclick=\"Common.Warning('<spring:message code='Cache.msg_apv_082' />');\">";
	  								}
	  								else {
	  									html += "<a href='#' class='timeline_item' data-type='"+ tableClass +"' onclick='clickSubject(\"" + v.GotoURL + "\", \"" + v.FormPrefix + "\", \"" + v.FormID + "\", \"" + v.BusinessData1 + "\", \"" + v.BusinessData2 + "\", \"" + v.TaskID + "\");'>";	
	  								}
	  								
	  								var cont = CFN_GetDicInfo(v.Context).split("<br/>");
	  								var formName 	  = cont.length > 1 ? cont[0] : "";
	  								var initiatorName = cont.length > 1 ? cont[1] : cont[0];
	  								
	  			                   	html += '<i class="item_badge"></i>';
	  			                   	html += '<em class="item_status">'+spanText+'</em>';
	  			                   	html += '<strong class="item_subject"><strong>'+ v.FormSubject.toString().replaceAll("<", "&lt;").replaceAll(">", "&gt;") + " " + CFN_GetDicInfo(v.Subject) +'</strong></strong>';
	  			                   	html += '<span class="item_form">'+ formName +'</span>';
	  			                   	html += '<span class="item_user">';
	  			                   	html += '    <span class="ui_avatar"><img src="/covicore/common/photo/photo.do?img='+ v.PhotoPath +'" alt="..." onerror="coviCmn.imgError(this, true)"></span>';
	  			                   	html += '    <span class="user_info">';
	  			                   	html += '        <strong>'+ initiatorName +'</strong>';
	  			                   	html += '        <time>' + v.viewRegDate + '</time>';
	  			                   	html += '    </span>';
	  			                   	html += '</span>';
	  								
	  								html += "</a>"
	  								html += "</li>";
	  							});
	  							html += "</li>";
							});
	  						html += "</ul>";
						});
					}else{
						html +='<div class="ui_empty"><p><spring:message code="Cache.msg_NoDataList"/></p></div>';	//조회할 목록이 없습니다.
						btimeLineEmpty = true;
					}
				}else{
					html +='<div class="ui_empty"><p><spring:message code="Cache.msg_NoDataList"/></p></div>';	//조회할 목록이 없습니다.
					btimeLineEmpty = true;
				}
				
				if(btimeLineEmpty){
				    $("#timeLine").closest("div .card_content").before(html).remove();
				}else{
					$("#timeLine").append(html);				    
				}

				$(".timeLine").slimScroll({
					height: $(".timeLine").height()+'px',
					alwaysVisible: true
				});
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/approval/legacy/getAlarmList.do", response, status, error);
			}
		});
	}
	// 제목 클릭
	function clickSubject(url, FormPrefix, FormID, BusinessData1, BusinessData2, TaskID){
		var width = 790;
		if (IsWideOpenFormCheck(FormPrefix, FormID) == true) {
			width = 1070;
		} else {
			width = 790;
		}
		
		CFN_OpenWindow(url+"&ExpAppID="+(typeof BusinessData2!="undefined"?BusinessData2:"")+"&taskID="+(typeof TaskID!="undefined"?TaskID:""), "", width, (window.screen.height - 100), "resize");
	}
	
	//결재함 (미결함(안읽은), 참조, 회람)
	function setListData(type){
		$.ajax({
			url:"/approval/user/getHomeApprovalListData.do",
			data: {
				"businessData1":"APPROVAL",
				"listType" : type
			},
			type:"post",
			success:function (data) {
				if(type == "APPROVAL"){
					setApprovalBoxListData(data.list.approval);
				}else if(type == "REF") {
					setCCInfoBoxListData(data.list.references);
				}else if(type == "CIRCULAR") {
					setCircularBoxListData(data.list.circular);
				}
				
				setApprovalCnt(data.cntinfo);
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/approval/user/getHomeApprovalListData.do", response, status, error);
			}
		});
	}
	
	// 미결목록
	function setApprovalBoxListData(data){
		$("#approval_list_ul").empty();
		var FormInstID = "";
		if(data.length > 0){
			$(data).each(function(index){
				var html = "";
				html += "<li>";
			    html += "<a href='#' class='status_item' onclick='onClickPopButton(\""+this.ProcessID+"\",\""+this.WorkItemID+"\",\""+this.PerformerID+"\",\""+this.ProcessDescriptionID+"\",\""+this.FormSubKind+"\",\"\",\"\",\""+this.FormID+"\",\"\",\""+this.UserCode+"\",\"APPROVAL\",\""+this.FormPrefix+"\",\""+this.BusinessData1+"\",\""+this.BusinessData2+"\",\""+this.TaskID+"\"); return false;'>";
		        html += "<span class='ui_avatar'>";
		        html += "<img src='"+ coviCmn.loadImage(this.PhotoPath) +"' onerror='coviCmn.imgError(this, true)'>";
		        html += "</span>";
		        html += "<span class='item_content'>";
		        html += "<strong class='subject'>";
		        html += this.FormSubject.toString().replaceAll("<", "&lt;").replaceAll(">", "&gt;");
		        html += "</strong>";
		        html += "<span class='info'>";
		        html += "<em class='meta'>"+ this.SubKind +"</em>";// 타입(서버에서 다국어변환되어 옴)
		        html += "<em class='meta'>"+ setUserFlowerName(this.InitiatorID, this.InitiatorName) +"</em>";// 기안자
		        html += "<em class='meta'>"+ CFN_GetDicInfo(this.InitiatorUnitName) +"</em>";// 부서
		        html += "<em class='meta'>"+ getStringDateToString('yyyy-MM-dd',this.Created) +"</em>";// 일자
		        html += "<em class='meta'>"+ CFN_GetDicInfo(this.FormName) +"</em>";// 양식
		        html += "</span>";
		        html += "</span>";
		        html += "</li>";
		        
				$("#approval_list_ul").append(html);
				$("#approval_list_empty").attr("hidden", true);
				$("#approval_list").removeAttr('hidden');
			});
		}else{
		    $("#approval_list").attr("hidden", true);
		    $("#approval_list_empty").removeAttr('hidden');
		}
	}

	// 참조목록
	function setCCInfoBoxListData(data){
		$("#approval_list_ul").empty();
		if(data.length > 0){
			$(data).each(function(index){
				
				var html = "";
				html += "<li>";
			    html += "<a href='#' class='status_item' onclick='onClickPopButton(\""+this.ProcessID+"\",\"\",\"\",\"\",\""+this.FormSubKind+"\",\"\",\"\",\""+this.FormID+"\",\"\",\"\",\"TCINFO\",\""+this.FormPrefix+"\",\""+this.BusinessData1+"\",\""+this.BusinessData2+"\",\"\"); return false;'>";
		        html += "<span class='ui_avatar'>";
		        html += "<img src='"+ coviCmn.loadImage(this.PhotoPath) +"' onerror='coviCmn.imgError(this, true)'>";
		        html += "</span>";
		        html += "<span class='item_content'>";
		        html += "<strong class='subject'>";
		        html += this.FormSubject.toString().replaceAll("<", "&lt;").replaceAll(">", "&gt;");
		        html += "</strong>";
		        html += "<span class='info'>";
		        html += "<em class='meta'>"+ setUserFlowerName(this.InitiatorID, CFN_GetDicInfo(this.InitiatorName)) +"</em>";// 기안자
		        html += "<em class='meta'>"+ CFN_GetDicInfo(this.InitiatorUnitName) +"</em>";// 부서
		        html += "<em class='meta'>"+ getStringDateToString('yyyy-MM-dd',this.RegDate) +"</em>";// 일자
		        html += "<em class='meta'>"+ CFN_GetDicInfo(this.FormName) +"</em>";// 양식
		        html += "</span>";
		        html += "</span>";
		        html += "</li>";

				$("#approval_list_ul").append(html);
				$("#approval_list_empty").attr("hidden", true);
				$("#approval_list").removeAttr('hidden');
			});
		}else{
		    $("#approval_list").attr("hidden", true);
		    $("#approval_list_empty").removeAttr('hidden');
		}
	}
	
	// 회람목록
	function setCircularBoxListData(data) {
		$("#approval_list_ul").empty();
		if(data.length > 0){
			$(data).each(function(index){
				
				var html = "";
				html += "<li>";
			    html += "<a href='#' class='status_item' onclick='onClickPopButton(\""+this.ProcessID+"\",\"\",\"\",\"\",\""+this.FormSubKind+"\",\"\",\"\",\""+this.FormID+"\",\"\",\"\",\"TCINFO\",\""+this.FormPrefix+"\",\""+this.BusinessData1+"\",\""+this.BusinessData2+"\",\"\"); return false;'>";
		        html += "<span class='ui_avatar'>";
		        html += "<img src='"+ coviCmn.loadImage(this.PhotoPath) +"' onerror='coviCmn.imgError(this, true)'>";
		        html += "</span>";
		        html += "<span class='item_content'>";
		        html += "<strong class='subject'>";
		        html += this.FormSubject.toString().replaceAll("<", "&lt;").replaceAll(">", "&gt;");
		        html += "</strong>";
		        html += "<span class='info'>";
		        html += "<em class='meta'>"+ setUserFlowerName(this.InitiatorID, CFN_GetDicInfo(this.InitiatorName)) +"</em>";// 회람지정자
		        html += "<em class='meta'>"+ getStringDateToString('yyyy-MM-dd',this.RegDate) +"</em>";// 일자
		        html += "<em class='meta'>"+ CFN_GetDicInfo(this.FormName) +"</em>";// 양식
		        html += "</span>";
		        html += "</span>";
		        html += "</li>";

				$("#approval_list_ul").append(html);
				$("#approval_list_empty").attr("hidden", true);
				$("#approval_list").removeAttr('hidden');
			});
		}else{
		    $("#approval_list").attr("hidden", true);
		    $("#approval_list_empty").removeAttr('hidden');
		}
	}
	
	// 미결/참조/회람 건수조회
	function setApprovalCnt(data) {
		if(data && data != undefined){
			$("em#cnt_unread_approval").html(data.ApprovalCnt);
			$("em#cnt_unread_reference").html(data.RefCnt);
			$("em#cnt_unread_circular").html(data.CircularCnt);
		}
	}

	//결재문서 조회 팝업
	function onClickPopButton(ProcessID,WorkItemID,PerformerID,ProcessDescriptionID,SubKind,FormTempInstBoxID,FormInstID,FormID,FormInstTableName,UserCode,mnid,FormPrefix,BusinessData1,BusinessData2,TaskID){
		var archived = "false";
		var mode;
		var gloct;
		var subkind;
		var archived;
		var userID;
		switch (mnid){
			case "PREAPPROVAL" : mode="PREAPPROVAL"; gloct = "PREAPPROVAL"; subkind="T010"; userID=UserCode; break;
			case "APPROVAL" : mode="APPROVAL"; gloct = "APPROVAL"; subkind=SubKind; userID=UserCode; break;
			case "PROCESS" : mode="PROCESS"; gloct = "PROCESS"; subkind=SubKind; userID=UserCode; break;
			case "COMPLETE" : mode="COMPLETE"; gloct = "COMPLETE"; subkind=SubKind; archived="true"; userID=UserCode; break;
			case "REJECT" : mode="REJECT"; gloct = "REJECT";  subkind=SubKind; archived="true"; userID=UserCode; break;
			case "TEMPSAVE" : mode="TEMPSAVE"; gloct = "TEMPSAVE"; subkind="";  userID=""; break;
			case "TCINFO" : mode="COMPLETE"; gloct = "TCINFO"; subkind=SubKind; userID=""; break;
		}
		var width = "790";
		if(IsWideOpenFormCheck(FormPrefix, FormID)){
			width = "1070";
		}else{
			width = "790";
		}
		
		var _win = CFN_OpenWindow("/approval/approval_Form.do?mode="+mode+"&processID="+ProcessID+"&workitemID="+WorkItemID+"&performerID="+PerformerID+"&processdescriptionID="+ProcessDescriptionID+"&userCode="+userID+"&gloct="+gloct+"&formID="+FormID+"&forminstanceID="+FormInstID+"&formtempID="+FormTempInstBoxID+"&forminstancetablename="+FormInstTableName+"&admintype=&archived="+archived+"&usisdocmanager=true&listpreview=N&subkind="+subkind
				+"&ExpAppID="+(typeof BusinessData2!="undefined"?BusinessData2:"")+"&taskID="+(typeof TaskID!="undefined"?TaskID:""), "", width, (window.screen.height - 100), "resize");
		
		_win.onload = function(){
			// reload
			var lType = $('.ui_dashboard_approval .tab_menu .tab[aria-selected="true"]').attr("lType");
			setListData(lType);
		};
	}
	
	// 지연문서 건수 조회
	function setApprovalDelayMsg(){
		$.ajax({
			url:"/approval/user/getHomeApprovalDelayCnt.do",
			data: {
				"businessData1":"APPROVAL"
			},
			type:"post",
			success:function (data) {
				if(data && data.status == "SUCCESS"){
					var delayPeriodDay = data.DelayPeriodDay;
					var cnt = data.cnt;
					
					var msg = "<spring:message code='Cache.msg_apv_dashboard_desc2'/>";
					msg = msg.replace("{0}", delayPeriodDay);
					msg = msg.replace("{1}", "<a href='#' onclick='CoviMenu_GetContent(\"/approval/layout/approval_ApprovalList.do?CLSYS=approval&CLMD=user&CLBIZ=Approval&mode=Approval\");'><em>"+cnt+"</em></a>");
					
					$("p#delayMsg").html(msg);
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/approval/user/getHomeApprovalListData.do", response, status, error);
			}
		});
	}
	
	// 즐겨찾는 양식목록 조회
	// 해제 가능, 추가는 기안작성 페이지에서 처리함.
	function setFavoriteUserForms() {
		$("#FavoriteFormList").empty();
		$.ajax({
			url:"/approval/user/getHomeFavorageFormListData.do",
			data: {},
			type:"POST",
			success:function (data) {
				if(data && data.status == "SUCCESS"){
					var html = "";
					if(data.list.length > 0){
						$(data.list).each(function(index){
							var datatype = "1";
							var className = CFN_GetDicInfo(this.FormClassName);
							var formName = CFN_GetDicInfo(this.FormName);
							var formDesc = "&nbsp;";
							
							if(this.FormIcon != undefined && this.FormIcon != "") datatype = this.FormIcon;
							html += '<div class="favorites_item" data-type="'+datatype+'" formid="'+ this.FormID +'">';
							
							html += '<a href="#" onclick="openFormDraft(\''+this.FormID+'\',\''+this.FormPrefix+'\');">';
							html += '<em>'+className+'</em><strong>'+formName+'</strong>';
							html += '</a>';
							if(this.FormDesc != undefined && this.FormDesc != ''){
							    formDesc = Base64.b64_to_utf8(this.FormDesc);
								html += '<div class="ui_help">';
								html += '	<button type="button" class="help_toggle"><span>Help</span></button>';
								html += '	<div class="help_message">';
								html += '		<div class="message_content">'+formDesc+'</div>';
								html += '	</div>';
								html += '</div>';
							}
							html += '<div class="move"></div>';
							html += '<button type="button" class="favorites ui_switch_toggle" formid="'+this.FormID+'" onclick="clearFavoriteForm(this)" aria-pressed="true"><span>&nbsp;</span></button>';
							
							html += '</div>';
						});
						$("#FavoriteFormList").html(html);
					}else{
						var $elem = $("#FavoriteFormList").closest(".card_content").empty();
					    html += '<div class="ui_empty">';
					    html += '	<p><spring:message code="Cache.msg_apv_101"/></p>'; <!-- 조회할 목록이 없습니다. -->
						html += '</div>';
						$elem.html(html);
					}
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/approval/user/getHomeApprovalListData.do", response, status, error);
			}
		});
	}
	
	// 즐겨찾기 해제하기
	function clearFavoriteForm(obj) {
		var formID = obj.getAttribute("formid");
		var pUrl = "/approval/user/removetFavoriteUsedFormListData.do";
		var pParam = {
			"formID" : formID
		};
		var pAsync = true;
		var pCallBack = function(data){
			if(data.status == "SUCCESS"){
				// reload.
				// setFavoriteUserForms();
				$(".favorites[formid="+formID+"]").closest("div.favorites_item").remove();
			}
		};
		CFN_CallAjax(pUrl, pParam, pCallBack, pAsync, "json");
	}
	
	// 즐겨찾기 양식 정렬저장
	function sortFormList(){
		var sortListArr = [];
		var sortList = $(".favorites_item", "#FavoriteFormList");
		for(var i = 0; i < sortList.length; i++){
			sortListArr.push(sortList[i].getAttribute("formid"));
		}
		var pUrl = "/approval/user/updateFavoriteUsedFormSort.do";
		var pParam = {
			"sortList" : sortListArr.join(";")
		};
		var pAsync = true;
		var pCallBack = function(data){
			if(data.status == "SUCCESS"){
				// do nothing.
			}
		};
		CFN_CallAjax(pUrl, pParam, pCallBack, pAsync, "json");
	}

	// 홈 탭(섹션) 순서 저장
	function sortHomeSectionTab(){
		var sortListArr = [];
		var sortList = $(".dashboard_card", ".dashboard_list");
		for(var i = 0; i < sortList.length; i++){
			sortListArr.push(sortList[i].getAttribute("type")); // widget_timeline, widget_status, widget_favorites
		}
		var pUrl = "/approval/user/updateHomeSectionSort.do";
		var pParam = {
			"sortList" : sortListArr.join(";")
		};
		var pAsync = true;
		var pCallBack = function(data){
			if(data.status == "SUCCESS"){
				approvalHome.toggleDashBoard(true);
			}
		};
		CFN_CallAjax(pUrl, pParam, pCallBack, pAsync, "json");
	}
	
	// 문서목록 탭 순서 저장
	function sortApprovalListTab(){
		var sortListArr = [];
		var sortList = $("button.tab", "#approval_list_tab");
		for(var i = 0; i < sortList.length; i++){
			sortListArr.push(sortList[i].getAttribute("ltype")); // REF, APPROVAL, CIRCULAR
		}
		var pUrl = "/approval/user/updateHomeListTabSort.do";
		var pParam = {
			"sortList" : sortListArr.join(";")
		};
		var pAsync = true;
		var pCallBack = function(data){
			if(data.status == "SUCCESS"){
				// do nothing.
			}
		};
		CFN_CallAjax(pUrl, pParam, pCallBack, pAsync, "json");
	}
	
  	// 컨텐츠 토글 버튼
	function toggleContents(obj) {
     	if ($(obj).attr('aria-pressed') === 'true') {
        	$(obj).removeAttr('aria-pressed');
         	$(obj).parents('.dashboard_card').removeAttr('aria-expanded');
     	} else {
         	$(obj).attr('aria-pressed', 'true');
         	$(obj).parents('.dashboard_card').attr('aria-expanded', 'true');
     	}
	}
	var approvalHome;
	$(document).ready(function(){
		approvalHome = new ApprovalHome();
		approvalHome.initHome();
	});
</script>