<%@ page language="java" contentType="text/html; charset=UTF-8"	pageEncoding="UTF-8"  import="egovframework.baseframework.util.SessionHelper,egovframework.baseframework.util.PropertiesUtil, egovframework.baseframework.util.SessionHelper,egovframework.coviframework.util.RedisDataUtil"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<style>
.inPerView{width:100%}
</style>
    <!-- 상단 끝 -->
    <div class="cRConTop titType">
        <h2 class="title"><spring:message code='Cache.lblAdminSetting' /></h2>
    </div>
    
    <div class="cRContCollabo mScrollVH">
<form id="frm">
        <!-- 컨텐츠 시작 -->
        <div class="ATMCont">
		<!-- 회사설정 탭메뉴 시작 -->
		<div class="ATM_Config_wrap">
			<ul class="tabMenu clearFloat">
				<li class="topToggle active"><a href="#"  ><spring:message code='Cache.lbl_SyncSetting'/></a></li>		<!-- 연동설정 -->
				<li class="topToggle"><a href="#"  ><spring:message code='Cache.lbl_menuManage'/></a></li>	<!-- 메뉴관리 -->
				<li class="topToggle"><a href="#"  ><spring:message code='Cache.lbl_TemplateList'/></a></li>	<!-- 템플릿 목록-->
				<li class="topToggle"><a href="#"  ><spring:message code='Cache.lbl_TemplateApproval'/></a></li>	<!-- 템플릿 승인 -->
				<!-- <li class="topToggle"><a href="#"  ><spring:message code='Cache.lbl_ProjectStat'/></a></li> -->	<!-- 프로젝트 통계 -->
			</ul>
		</div>
		
		<div style="margin: 25px;">
			
			<!-- 탭1 -->
			<div class="tabContent active">
				<div class="ATM_Config_Table_wrap">
					<p class="ATM_Config_Title"><spring:message code='Cache.lbl_SyncSetting'/></p>		<!-- 연동설정 -->
					<div class="ATM_Config_TW">
						<table class="ATM_Config_Table" cellpadding="0" cellspacing="0">
							<tbody>
								<tr>
									<td class="Config_TH"><p class="tx_TH"><spring:message code='Cache.lbl_apv_approval'/> <spring:message code='Cache.lbl_apv_linkage'/></p></td>	<!-- 전자결재 연동 -->
									<td width="80"><div class="alarm type01"><a href="#" class="onOffBtn" id="ApprovalUseYn"><span></span></a></div></td>
									<td>
										<p class="Config_mp"><spring:message code='Cache.msg_collab_admin1'/></p>
										<p class="Config_sp"><spring:message code='Cache.msg_collab_admin2'/></p>
									</td>
								</tr>
								
								<%if (RedisDataUtil.getBaseConfig("isUseMail").equals("Y")){ %>
								<tr>
									<td class="Config_TH"><p class="tx_TH"><spring:message code='Cache.lbl_Mail'/> <spring:message code='Cache.lbl_apv_linkage'/></p></td>	<!-- 메일 연동 -->
									<td width="80"><div class="alarm type01"><a href="#" class="onOffBtn" id="MailUseYn"><span></span></a></div></td>
									<td>
										<p class="Config_mp"><spring:message code='Cache.msg_collab_admin3'/></p>
										<p class="Config_sp"><spring:message code='Cache.msg_collab_admin4'/></p>
									</td>
								</tr>
								<%} %>
								
								<tr>
									<td class="Config_TH"><p class="tx_TH"><spring:message code='Cache.lbl_Messanger'/> <spring:message code='Cache.lbl_apv_linkage'/></p></td>	<!-- 메신저 연동 -->
									<td width="80"><div class="alarm type01"><a href="#" class="onOffBtn" id="MessengerUseYn"><span></span></a></div></td>
									<td>
										<p class="Config_mp"><spring:message code='Cache.msg_collab_admin5'/></p>
										<p class="Config_sp"><spring:message code='Cache.msg_collab_admin6'/></p>
									</td>
								</tr>
								
								<tr>
									<td class="Config_TH"><p class="tx_TH"><spring:message code='Cache.BizSection_Survey'/> <spring:message code='Cache.lbl_apv_linkage'/></a></p></td>	<!-- 설문 연동 -->
									<td width="80"><div class="alarm type01"><a href="#" class="onOffBtn" id="SurveyUseYn"><span></span></a></div></td>
									<td>
										<p class="Config_mp"><spring:message code='Cache.msg_collab_admin7'/></p>
										<p class="Config_sp"><spring:message code='Cache.msg_collab_admin8'/></p>
									</td>
								</tr>
								
								<tr>
									<td class="Config_TH"><p class="tx_TH"><spring:message code='Cache.lbl_Schedule'/> <spring:message code='Cache.lbl_apv_linkage'/></p> </a></td>	<!-- 일정 연동 -->
									<td width="80"><div class="alarm type01"><a href="#" class="onOffBtn" id="ScheduleUseYn"><span></span></a></div></td>
									<td>
										<p class="Config_mp"><spring:message code='Cache.msg_collab_admin9'/></p>
										<p class="Config_sp"><spring:message code='Cache.msg_collab_admin10'/></p>
									</td>
								</tr>
								
							</tbody>
						</table>
					</div>
					
					<div class="bottom">
						<a href="#" class="btnTypeDefault btnTypeBg createCSBtn"><spring:message code='Cache.lbl_Save'/></a>
					</div>
				</div>
			</div>
		
			<!-- 탭2 -->
			<div class="tabContent">
				<div class="ATM_Config_Table_wrap">
					<p class="ATM_Config_Title"><spring:message code='Cache.lbl_menuManage'/></p>		<!-- 메뉴관리 -->
					<div class="ATM_Config_TW">
						<table class="ATM_Config_Table" cellpadding="0" cellspacing="0">
							<tbody>
							
								<tr>
									<td class="Config_TH"><p class="tx_TH"><spring:message code='Cache.lbl_ProgressState'/> <spring:message code='Cache.lbl_Menu'/> <spring:message code='Cache.lbl_Use'/></p></td>	<!-- 진행상태 메뉴 사용 -->
									<td width="80"><div class="alarm type01"><a href="#" class="onOffBtn" id="StatMenuUseYn"><span></span></a></div></td>
									<td>
										<p class="Config_mp"><spring:message code='Cache.msg_collab_admin11'/></p>
										<p class="Config_sp"><spring:message code='Cache.msg_collab_admin12'/></p>
									</td>
								</tr>
								<tr>
									<td class="Config_TH"><p class="tx_TH"><spring:message code='Cache.lbl_work_explanation' /><br/><spring:message code='Cache.lbl_apv_setform_UseEditYN_desc' /></p></td> <!-- 업무설명 웹에디터 사용 유무 -->
									<td width="80"><div class="alarm type01"><a href="#" class="onOffBtn" id="DescEditorUseYn"><span></span></a></div></td>
									<td>
										<p class="Config_mp">도메인 별 업무설명에 에디터 사용 유무를 설정합니다.</p>
									</td>
								</tr>
							</tbody>
						</table>
					</div>
					
					<div class="bottom">
						<a href="#" class="btnTypeDefault btnTypeBg createCSBtn"><spring:message code='Cache.lbl_Save'/></a>
					</div>
				</div>
			</div>
			
			<!-- 탭3 -->
			<div class="tabContent">
				
				<div class="temp_cont">
					<div class="main_Titbox main_Titbox02">
						<h2 class="title"><spring:message code='Cache.lbl_mainCategory' /></h2> <!-- 주요카테고리 -->
						<div class="searchBox02">
					        <span><input type="text" id="searchText"  /><button type="button" class="btnSearchType01"  id="icoSearch"><spring:message code='Cache.btn_search' /></button></span> <!-- 검색 -->
					    </div>
					</div>
					<div class="temp_cate_list">
						<ul>
							<c:forEach items="${tmlpKind}" var="list" varStatus="status">
								<li class="${list.Reserved1}"><a href="#" data-kind="${list.Code}"><strong>${list.CodeName}</strong></a></li>
							</c:forEach>
						</ul>
					</div>
				
					<div class="main_Titbox">
						<h2 class="title"  id="tmplTitle"><spring:message code='Cache.lbl_Business2' /></h2> <!-- 사업 -->
						<a href="#" class="btnTypeDefault_r middle1 mailico_filter"><spring:message code='Cache.lbl_Filter' /></a> <!-- 필터 -->
					</div>
					<div class="project_manage">
						<ul>
						</ul>
					</div>
				</div>
			</div>
			
			<!-- 탭4 -->
			<div class="tabContent" id="collabTmplRequest">
				<div class="temp_cont">
					<div class="pagingType02 buttonStyleBoxLeft">
						<a href="#" class="btnTypeDefault  btnTypeBg" id="btnApproval"><spring:message code="Cache.lbl_apv_Approved"/></a>
						<a href="#" class="btnTypeDefault" id="btnReject"><spring:message code="Cache.lbl_Reject"/></a>
					</div>
					<span class="TopCont_option">
						<input id="ReqStatus" value="Y" type="checkbox" checked class="check_class">
						<label for=ReqStatus><spring:message code="Cache.lbl_adstandby"/></label><!-- 승인대기건만-->
			
						<button href="#" class="btnRefresh" type="button" id="btnRefresh"></button>
						<select class="selectType02 listCount" id="selectSize">
							<option>5</option>
							<option selected>10</option>
							<option>20</option>
							<option>30</option>
						</select>
					</span>
								<!-- 승인 의견 레이어 팝업 시작-->
						<div class="layer_divpop" style="width:440px; left:170px; z-index:104;display:none"  id="divWork">
							<div class="divpop_contents">
								<div class="pop_header"><h4 class="divpop_header"><span class="divpop_header_ico"><spring:message code="Cache.lbl_apv_comment_write"/></span></h4><a onclick='$("#divWork").hide()'  class="divpop_close" style="cursor:pointer;"></a></div>
								<div class="divpop_body" style="overflow:hidden; padding:0;">
									<div class="ATMgt_popup_wrap">
										<div class="ATMgt_opinion_wrap">
											<table class="ATMgt_popup_table" cellpadding="0" cellspacing="0">
												<tbody>
													<tr>	
														<td class="ATMgt_T_th"><spring:message code="Cache.lbl_comment"/></td>
														<td><textarea id="ApprovalRemark" name="ApprovalRemark" class="ATMgt_Tarea"  cols="30" rows="40"></textarea>
													</tr>
												</tbody>
											</table>
										</div>
										<div class="bottom">
											<a href="#" class="btnTypeDefault  btnTypeBg btnAttAdd" id="btnSaveApproval"><spring:message code="Cache.lbl_apv_Approved"/></a>
											<a href="#" class="btnTypeDefault" id="btnSaveReject"><spring:message code="Cache.lbl_Reject"/></a>
											<a href="#" class="btnTypeDefault" onclick='$("#divWork").hide()'><spring:message code="Cache.btn_Close"/></a>
										</div>
									</div>
								</div>
							</div>
						</div>	
					<div class="tblList">
						<div id="collabTmplRequestGridDiv"></div>
					</div>
				</div>	
			</div>
			
			<!-- 탭5 -->
			<div class="tabContent">
			</div>
		
		</div>
		
	</div>
		<!-- 컨텐츠 끝 -->
</form>
    </div>

 
<script type="text/javascript">   
//연동 설정 & 메뉴관리
var collabSyncSetting = {
		objectInit : function(){
			this.addEvent();
			this.searchData();
		}	,
		addEvent : function(){
			$(".createCSBtn").on('click',function(){
				collabSyncSetting.saveSyncSetting();
			});
			
			$(".topToggle").on('click',function(){
				$(".topToggle").attr("class","topToggle");
				$(".topToggle").eq($(this).index()).attr("class","topToggle active");
				$(".tabContent").removeClass("active");
				$(".tabContent").eq($(this).index()).addClass("active");
				
				//탭 초기화
				if($(this).index() == 2){	// 템플릿 목록
					collabTmplList.objectInit();
				}else if($(this).index() == 3){	// 템플릿 승인
					collabTmplRequest.objectInit();
				}
			});
			
			$(".onOffBtn").on('click',function(){
				if($(this).attr("class").lastIndexOf("on") > 0 ) {
					$(this).removeClass("on");
				}else{
					$(this).addClass("on");			
				}
			});
		},
		searchData:function(){
			
			$.ajax({
				type:"POST",
				url:"/groupware/collabAdmin/getSyncSetting.do",
				success:function (data) {
					var result = data.data;
					//연동설정
					if(result.isUseCollabApproval=="Y") $("#ApprovalUseYn").addClass("on");
					if(result.isUseCollabMail=="Y") $("#MailUseYn").addClass("on");
					if(result.isUseCollabMessenger=="Y") $("#MessengerUseYn").addClass("on");
					if(result.isUseCollabSurvey=="Y") $("#SurveyUseYn").addClass("on");					
					if(result.isUseCollabSchedule=="Y") $("#ScheduleUseYn").addClass("on");
					
					//메뉴관리
					if(result.isUseCollabStatMenu=="Y") $("#StatMenuUseYn").addClass("on");
					if(result.isUseCollabDescEditor == "Y") $("#DescEditorUseYn").addClass("on");
				} 
			});
		},
		saveSyncSetting : function(){
			var data = $("#frm").serializeObject();
			//연동설정
			data.isUseCollabApproval = $("#ApprovalUseYn").attr("class").lastIndexOf("on") > 0 ? "Y":"N";
			data.isUseCollabMail = $("#MailUseYn").attr("class").lastIndexOf("on") > 0 ? "Y":"N";
			data.isUseCollabMessenger = $("#MessengerUseYn").attr("class").lastIndexOf("on") > 0 ? "Y":"N";
			data.isUseCollabSurvey = $("#SurveyUseYn").attr("class").lastIndexOf("on") > 0 ? "Y":"N";
			data.isUseCollabSchedule = $("#ScheduleUseYn").attr("class").lastIndexOf("on") > 0 ? "Y":"N";
			
			//메뉴관리
			data.isUseCollabStatMenu = $("#StatMenuUseYn").attr("class").lastIndexOf("on") > 0 ? "Y":"N";
			data.isUseCollabDescEditor = $("#DescEditorUseYn").attr("class").lastIndexOf("on") > 0 ? "Y":"N";
			
			//기초설정 변경 후 CACHE초기화
			$.ajax({
				url:"/groupware/collabAdmin/setSyncSetting.do",
				type:"post",
				data:data,
				dataType:"json",
				success : function(res) { 
					if (res.status == "SUCCESS") {
						Common.Confirm("<spring:message code='Cache.msg_SuccessRegist' /> <br><spring:message code='Cache.msg_ChgReload' /> <br><spring:message code='Cache.msg_TabReload'/>. <br><spring:message code='Cache.msg_ConfirmReload'/>", "Confirmation Dialog", function (confirmResult) {
							if(confirmResult){
								collabSyncSetting.reloadCache();
							}
						});
					}else {
						Common.Warning("<spring:message code='Cache.msg_apv_030' />");
					}
				},
				error:function(response, status, error){
					CFN_ErrorAjax("/groupware/adminSetting/setCompanySetting.do", response, status, error);
				}
			});
		},
		reloadCache : function(){
			localCache.removeAll();
			coviStorage.clear("CONFIG");
			
			$.ajax({
				url:"/covicore/cache/reloadCache.do",
					type:"post",
					data:{
						"replicationFlag": coviCmn.configMap["RedisReplicationMode"],
						"cacheType" : "BASECONFIG"
					},
					success: function (res) { 
						Common.Inform("<spring:message code='Cache.msg_Processed' />","Information",function(){
							location.reload();
			    		});
					},
					error : function (error){
						alert("error : "+error);
					}
				});
		}
}

//템플릿 목록
var collabTmplList = {
		objectInit : function(){		
			this.addEvent();
			this.searchData('BUSINESS');
			
			$(".searchBox02").attr("style","position: absolute;top: 0px;right: 25px;");
		}	,
		addEvent : function(){
			//const slider = $(".temp_cate_list ul");
			$(".temp_cate_list ul").slick({
			    slide: 'li',		//슬라이드 되어야 할 태그 ex) div, li
			    infinite : false, 	//무한 반복 옵션
			    slidesToShow : 7,		 //한 화면에 보여질 컨텐츠 개수
			    slidesToScroll : 1,		//스크롤 한번에 움직일 컨텐츠 개수
			    speed : 500,	  //다음 버튼 누르고 다음 화면 뜨는데까지 걸리는 시간(ms)
			    arrows : true, 		 //옆으로 이동하는 화살표 표시 여부
			    dots : false, 		 //스크롤바 아래 점으로 페이지네이션 여부
			    autoplay : false,			 //자동 스크롤 사용 여부
			    autoplaySpeed : 3000, 		 //자동 스크롤 시 다음으로 넘어가는데 걸리는 시간 (ms)
			    pauseOnHover : true,		 //슬라이드 이동	시 마우스 호버하면 슬라이더 멈추게 설정
			    vertical : false,		 //세로 방향 슬라이드 옵션
			    draggable : false, 	//드래그 가능 여부
			    variableWidth: false,
			    centerMode: false,
			    responsive: [ // 반응형 웹 구현 옵션
						{
							breakpoint: 1600, //화면 사이즈 1600px
							settings: {
								//위에 옵션이 디폴트 , 여기에 추가하면 그걸로 변경
								slidesToShow:6
							}
						},
						{
							breakpoint: 1400, //화면 사이즈 1400px
							settings: {
								//위에 옵션이 디폴트 , 여기에 추가하면 그걸로 변경
								slidesToShow:5
							}
						}
					]
			  });
			
			//검색
			$(document).off('click','#icoSearch').on('click','#icoSearch',function(){
				$("#tmplTitle").text("<spring:message code='Cache.lbl_all' />");
				collabTmplList.searchData( $(this).data("kind"), $("#searchText").val());
		    });
			
			//엔터검색
			$(document).off('keypress','#searchText').on('keypress','#searchText',function(e){
				if (e.which == 13) {
					e.preventDefault();
					$("#tmplTitle").text("<spring:message code='Cache.lbl_all' />");
					collabTmplList.searchData( $("#icoSearch").data("kind"), $(this).val());
			    }
			});
			  
			$(document).off('click','.pr_like').on('click','.pr_like',function(e){
				e.stopPropagation();
				coviComment.addLikeCount(this, 'CollabTmpl', $(this).data("tmplSeq"));
				$(this).toggleClass("active");
		    });
			$(document).off('click','.temp_cate_list a').on('click','.temp_cate_list a',function(){
				$("#tmplTitle").text($(this).find("strong").text());
				$("#tmplTitle").val($(this).data("kind"));
				
				collabTmplList.searchData( $(this).data("kind"));
		    });
			
			$(document).off('click','.btn_card_delete').on('click','.btn_card_delete',function(e){
				e.stopPropagation();
				var aJsonArray = new Array();
				aJsonArray.push({"tmplSeq":$(this).data("tmplSeq")});
				
				Common.Confirm("<spring:message code='Cache.msg_RUDelete' />", "Confirmation Dialog", function (confirmResult) {
					if (confirmResult) {
						$.ajax({
							type:"POST",
							contentType:'application/json; charset=utf-8',
							dataType   : 'json',
							data:JSON.stringify({"dataList" : aJsonArray }),
							url:"/groupware/collabTmpl/deleteTmplRequest.do",
							success:function (data) {
								if(data.result == "ok"){
									Common.Inform("["+data.resultCnt+"<spring:message code='Cache.lbl_DocCount'/>] <spring:message code='Cache.msg_com_processSuccess'/>");	//저장되었습니다.
									collabTmplList.searchData($("#tmplTitle").val());
								}
								else{
									Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+data); //	오류가 발생했습니다. 관리자에게 문의바랍니다
								}
							},
							error:function (request,status,error){
								Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
							}
						});
					}
				});	
			});	
			
			//템플릿 상세
			$(document).off('click','.project_manage  ul li').on('click','.project_manage  ul li',function(){
				var popupID	= "CollabTmplViewPopup";
		 		var openerID	= "";
		 		var popupYN		= "N";
		 		var popupUrl	= "/groupware/collabTmpl/CollabTmplSavePopup.do?"
		 						+ "&tmplSeq="+$(this).data("tmplSeq")
		 						+ "&tmplName="+encodeURI( $(this).find(".pr_tit").text())
		 						+ "&popupID="	 + popupID;
				Common.open("", popupID, $(this).find(".pr_tit").text(), popupUrl, "1600", "800", "iframe", true, null, null, true);

				
			});
		},
		searchData:function(tmplKind, tmplName){
			if (tmplName == undefined) tmplName = "";

			var params = {"tmplKind" : tmplKind, "tmplName" : tmplName };
			$.ajax({
	    		type:"POST",
	    		data:params,
	    		url:"/groupware/collabTmpl/getTmplList.do",
	    		success:function (data) {
	    			  $(".project_manage ul").empty();
	    			  data.list.map( function( item,idx ){
	    				  $(".project_manage  ul").append( $("<li>",{"class":"icon03"})
	    						  .append($("<strong>",{"class":"pr_tit"}).text(item.TmplName)).data({"tmplSeq":item.TmplSeq})
	    						  .append($("<span>",{"class":"pr_txt"}).text(item.Remark))
	    						  .append($("<div>",{"class":"pr_info02"})
	    								  .append($("<span>",{"class":"pr_manage"}).text(item.TmplKindName))
	    								  .append($("<a>",{"class":"pr_like" + (item.MyLikeCnt>0?" active":"")}).data({"tmplSeq":item.TmplSeq}).append($("<span>",{"name":"likeCnt"}).text(item.LikeCnt)))
	    								  .append($("<a>",{"class":"btn_card_delete"}).data({"tmplSeq":item.TmplSeq}))
	    							)) ;
	    			});
	    		},
	    		error:function (request,status,error){
	    			Common.Error(Common.getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
	    		}
	    	});
		}
}

// 템플릿 승인
var collabTmplRequest = {
		grid:'',
		objectInit : function(){		
			this.makeGrid();
			this.addEvent();
			this.searchData(1);
		}	,
		makeGrid :function(){
			var configObj = {	targetID : "collabTmplRequestGridDiv",height : "auto",
					page : {pageNo: 1,pageSize: 10,},
					paging : true};
			var headerData =  [ 
				       {key:'chk', label:'chk', width:'30', align:'center', formatter:'checkbox', disabled: function (){
				    	    return this.item.RequestStatus!=='ApprovalRequest';
				       }},
						{key:'TmplKindName',			label:"<spring:message code='Cache.lbl_SchDivision' />",			width:'90', align:'center'},		//요청종류
						{key:'URName',  label:'<spring:message code="Cache.lbl_RequestUser" />', width:'90', align:'center'}, 	//요청자
						{key:'RequestTitle',  label:'<spring:message code="Cache.lbl_Title" />', width:'150', align:'left',
							formatter : function () {
				           		 return "<a id='reqInfo' data-map='" + JSON.stringify(this.item) + "'  class='gridLink'>"+this.item.RequestTitle+"</a>";
							}
						},
						{key:'RequestRemark',  label:'<spring:message code="Cache.lbl_sms_send_contents" />', width:'250', align:'left',
							formatter : function () {
				           		 return this.item.RequestRemark;
							}
						},
						{key:'StatusName',  label:'<spring:message code="Cache.lbl_VendorStatus" />', width:'70', align:'center',
							formatter : function () {
								var className = "";
								switch (this.item.RequestStatus)
								{
									case "ApprovalRequest": //승인요청
										className ="stay";
										break;
									case "Approval": //완료
										className ="comp";
										break;
									case "Reject"://반려
										className ="stay";
										break;
									case "ApprovalCancel"://신청철회
										className ="stay";
										break;
								}
				           		 return "<p class='tx_status "+className+"'>"+this.item.StatusName+"</p>";
							}
						},
						{key:'RegisteDate',  label:'<spring:message code="Cache.lbl_Application_Day" />', width:'120', align:'center', formatter : function () { return AttendUtils.maskDateTime(CFN_TransLocalTime(this.item.RegisteDate))}},
						{key:'RequestStatus',  label:'<spring:message code="Cache.TodoMsgType_Approval" />', width:'150', align:'center', sort:false,
							formatter : function () {
								if (this.item.RequestStatus== "ApprovalRequest"){ //승인요청
									return "<a class='btn_Ok' id='btnOk'><spring:message code='Cache.lbl_apv_Approved'/></a><a class='btn_No' id='btnNo'><spring:message code='Cache.lbl_Reject'/></a>";
								}	
								else{
									return "<a class='btn_Approval' href='#'>"+this.item.StatusName+"</a>";
								}
							}
						}
				];
			collabTmplRequest.grid = new coviGrid();
			collabTmplRequest.grid.setGridHeader(headerData);
			collabTmplRequest.grid.setGridConfig(configObj);
		},
		addEvent : function(){
			$('#collabTmplRequest #selectSize' ).on( 'change', function(e){
				collabTmplRequest.searchData(1);
			});
			
			$('#collabTmplRequest #btnSearch, #collabTmplRequest .btnRefresh, #collabTmplRequest .check_class' ).on( 'click', function(e){
				collabTmplRequest.searchData(1);
			});

			//승인화면
			$(document).on("click","#btnOk",function(){
				gMode="DIV";
				$("#ApprovalRemark").val("");
				$("#divWork").show();
				$("#btnSaveApproval").show();
				$("#btnSaveReject").hide();
			});
			
			$("#btnApproval").click(function(){
				if(!collabTmplRequest.validationChk())     	return ;
				gMode = "";
				$("#ApprovalRemark").val("");
				$("#divWork").show();
				$("#btnSaveApproval").show();
				$("#btnSaveReject").hide();
			});	

			//거부
			$(document).on("click","#btnNo",function(){
				gMode="DIV";
				$("#ApprovalRemark").val("");
				$("#divWork").show();
				$("#btnSaveApproval").hide();
				$("#btnSaveReject").show();
				
			});
			
			$("#btnReject").click(function(){
				if(!collabTmplRequest.validationChk())     	return ;
				gMode = "";
				$("#ApprovalRemark").val("");
				$("#divWork").show();
				$("#btnSaveApproval").hide();
				$("#btnSaveReject").show();
			});	
			

			$("#btnSaveApproval").click(function(){
				if(gMode == "" && !collabTmplRequest.validationChk())     	return ;
				Common.Confirm("<spring:message code='Cache.msg_TFAsk_apv' />", "Confirmation Dialog", function (confirmResult) {
					if (confirmResult) {
						var aJsonArray = new Array();
						if (gMode == ""){
							var selectObj = collabTmplRequest.grid.getCheckedList(0);
							for(var i=0; i<selectObj.length; i++){
		                        aJsonArray.push({"requestSeq":selectObj[i].RequestSeq,
												"prjSeq":selectObj[i].PrjSeq,
												"tmplName":selectObj[i].RequestTitle});
							}
						}
						else{
							aJsonArray.push({"requestSeq":collabTmplRequest.grid.getSelectedItem()["item"]["RequestSeq"],
											  "prjSeq":collabTmplRequest.grid.getSelectedItem()["item"]["PrjSeq"]});
						}
						
						$.ajax({
							type:"POST",
							contentType:'application/json; charset=utf-8',
							dataType   : 'json',
							data:JSON.stringify({"dataList" : aJsonArray  , "approvalRemark":$("#ApprovalRemark").val()}),
							url:"/groupware/collabTmpl/approvalTmplRequest.do",
							success:function (data) {
								if(data.status=='SUCCESS'){
									Common.Inform("["+data.resultCnt+"<spring:message code='Cache.lbl_DocCount'/>] <spring:message code='Cache.msg_com_processSuccess'/>");	//저장되었습니다.
									collabTmplRequest.searchData(1);
									$("#divWork").hide();
								}else{
				            		Common.Warning("<spring:message code='Cache.msg_apv_030'/>");
									$("#divWork").hide();
					            }	
							},
							error:function (request,status,error){
								Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
							}
						});
					}	
				});				
			});
			
			//거부
			$("#btnSaveReject").click(function(){
				if(gMode == "" && !collabTmplRequest.validationChk())     	return ;
				Common.Confirm("<spring:message code='Cache.msg_RUReject' />", "Confirmation Dialog", function (confirmResult) {
					if (confirmResult) {
						var aJsonArray = new Array();
						if (gMode == ""){
							var selectObj = collabTmplRequest.grid.getCheckedList(0);
							for(var i=0; i<selectObj.length; i++){
		                        aJsonArray.push({"requestSeq":selectObj[i].RequestSeq,
												"prjSeq":selectObj.PrjSeq});
							}
						}
						else{
							aJsonArray.push({"requestSeq":collabTmplRequest.grid.getSelectedItem()["item"]["RequestSeq"],
											"prjSeq":collabTmplRequest.grid.getSelectedItem()["item"]["PrjSeq"]});
						}

						
						$.ajax({
							type:"POST",
							contentType:'application/json; charset=utf-8',
							dataType   : 'json',
							data:JSON.stringify({"dataList" : aJsonArray  , "approvalRemark":$("#ApprovalRemark").val()}),
							url:"/groupware/collabTmpl/rejectTmplRequest.do",
							success:function (data) {
								if(data.result == "ok"){
									Common.Inform("["+data.resultCnt+"<spring:message code='Cache.lbl_DocCount'/>] <spring:message code='Cache.msg_com_processSuccess'/>");	//저장되었습니다.
									collabTmplRequest.searchData(1);
									$("#divWork").hide();
								}
								else{
									Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+data); //	오류가 발생했습니다. 관리자에게 문의바랍니다
								}
							},
							error:function (request,status,error){
								Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
							}
						});
					}	
				});				
			});	
			
			//페이지 이동
			$(document).on("click","#reqInfo",function(){
				var obj = collabTmplRequest;
				var gridData = obj.grid.getSelectedItem();
				var item = gridData["item"];
				if (item.RequestStatus == "Approval"){
					var popupID	= "CollabTmplViewPopup";
			 		var openerID	= "";
			 		var popupYN		= "N";
			 		var popupUrl	= "/groupware/collabTmpl/CollabTmplSavePopup.do?"
			 						+ "&tmplSeq="+item.TmplSeq
			 						+ "&tmplName="+encodeURI(item.RequestTitle)
			 						+ "&popupID="	 + popupID;
					Common.open("", popupID, $(this).find(".pr_tit").text(), popupUrl, "1600", "800", "iframe", true, null, null, true);
				}else{				
					//				collabMenu.goTab(this, objId, prjName, "MAIN", "/groupware/collab/CollabMain.do?param="+encodeURI($(this).text()),dataMap);
					var popupID	= "CollabProjectAllocPopup";
			 		var openerID	= "";
			 		var popupYN		= "N";
			 		var popupUrl	= "/groupware/collab/CollabMainView.do?"
			 						+ "&prjSeq="+item.PrjSeq
			 						+ "&prjName="+encodeURI(item.RequestTitle)
			 						+ "&popupID="	 + popupID;
					Common.open("", popupID, "", popupUrl, "1600", "800", "iframe", true, null, null, true);
				}
			});				
			
		},
		validationChk:function(){
			var listobj = collabTmplRequest.grid.getCheckedList(0);
			var aJsonArray = new Array();
			if(listobj.length == 0){
				Common.Warning("<spring:message code='Cache.msg_SelectTarget'/>");
				return false;
			}
			return true;
		},
		searchData:function(pageNo){
			var params = { "reqStatus":$('#collabTmplRequest #ReqStatus' ).is(":checked")?"Y":""};
			if (pageNo !="-1"){
				collabTmplRequest.grid.page.pageNo =pageNo;
				this.grid.page.pageSize = $('#collabTmplRequest #selectSize').val();
			}	
			// bind
			collabTmplRequest.grid.bindGrid({
				ajaxPars : params,
				ajaxUrl:"/groupware/collabTmpl/getTmplRequestList.do"
			});

		}
}

$(document).ready(function(){
	collabSyncSetting.objectInit();
});
</script>
    
    
    
    