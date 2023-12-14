<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@page import="egovframework.baseframework.util.SessionHelper"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%
	String userID 				= SessionHelper.getSession("USERID");
	String cookie 				= "N";
	String listChangeVal 		= "737";
	Cookie[] cookies  			= request.getCookies();
	for(int i = 0; i < cookies.length; i++){
		if(cookies[i].getValue().equals(userID)){
			for(int j= 0; j < cookies.length; j++){
				if(cookies[j].getName().equals("ListViewCookie")){
					cookie = cookies[j].getValue();
				}
				if(cookies[j].getName().equals("ListChangeVal")){
					listChangeVal = cookies[j].getValue();
				}
			}
		}
	}
	
	// 이전 검색 조건 세팅
	String schFrmSeBizID = request.getParameter("schFrmSeBizID") == null ? "" : request.getParameter("schFrmSeBizID");
	String schFrmSeBizNm = request.getParameter("schFrmSeBizNm") == null ? "" : request.getParameter("schFrmSeBizNm");
	String schFrmSeGroupID = request.getParameter("schFrmSeGroupID") == null ? "" : request.getParameter("schFrmSeGroupID");
	String schFrmSearchInput = request.getParameter("schFrmSearchInput") == null ? "" : request.getParameter("schFrmSearchInput");
	String schFrmSeSearchID = request.getParameter("schFrmSeSearchID") == null ? "" : request.getParameter("schFrmSeSearchID");
	String schFrmSeGroupWord = request.getParameter("schFrmSeGroupWord") == null ? "" : request.getParameter("schFrmSeGroupWord");
	String schFrmTabId = request.getParameter("schFrmTabId") == null ? "" : request.getParameter("schFrmTabId");
	
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<script type="text/javascript" src="/approval/resources/script/user/ApprovalListCommon.js<%=resourceVersion%>"></script>

<form name="IframeFrom" method="post">
	<input type="hidden" id="ProcessID" 			name="ProcessID" 			value="">
	<input type="hidden" id="WorkItemID" 			name="WorkItemID" 			value="">
	<input type="hidden" id="PerformerID" 			name="PerformerID" 			value="">
	<input type="hidden" id="ProcessDescriptionID" 	name="ProcessDescriptionID" value="">
	<input type="hidden" id="FormTempInstBoxID" 	name="FormTempInstBoxID" 	value="">
	<input type="hidden" id="FormInstID" 			name="FormInstID" 			value="">
	<input type="hidden" id="FormID" 				name="FormID" 				value="">
	<input type="hidden" id="FormInstTableName" 	name="FormInstTableName" 	value="">
	<input type="hidden" id="Mode" 					name="Mode" 				value="">
	<input type="hidden" id="Gloct" 				name="Gloct" 				value="">
	<input type="hidden" id="Subkind" 				name="Subkind" 				value="">
	<input type="hidden" id="Archived" 				name="Archived" 			value="">
	<input type="hidden" id="UserCode" 				name="UserCode" 			value="">
	<input type="hidden" id="Admintype" 			name="Admintype" 			value="">
	<input type="hidden" id="Usisdocmanager" 		name="Usisdocmanager" 		value="true">
	<input type="hidden" id="Listpreview" 			name="Listpreview" 			value="Y">
	<input type="hidden" id="BusinessData1" 		name="BusinessData1" 		value="">
	<input type="hidden" id="BusinessData2" 		name="BusinessData2" 		value="">
</form>
<div class="cRConTop titType">
	<h2 class="title"><spring:message code='Cache.lbl_apv_BizDoc'/></h2><!-- 업무문서함 -->
	
	<%-- <span class="topstit_n"><spring:message code='Cache.lbl_apv_BizDoc'/> : </span> --%>
	<div class="selBox" style="min-width: 184px;" id="bizDocSelectBox"></div>
	
	<div class="searchBox02">
		<div class="selBox" style="width: 100px;" id="selectSearchType"></div>
		<span><input type="text" class="sm" id="searchInput"  onkeypress="if (event.keyCode==13){ $('#simpleSearchBtn').click(); return false;}" ><button id="simpleSearchBtn"  type="button" onclick="onClickSearchButton(this);" class="btnSearchType01"><spring:message code='Cache.lbl_search'/><!-- 검색 --></button></span>
	</div>
</div>
<div class="cRContBottom mScrollVH ">
	<div class="apprvalContent">
		<div class="apprvalBottomCont">
			<div class="AXTabsLarge">
				<div id="divTabTray" class="AXTabsTray">
					<a id="aProcessPage" onclick="clickTab(this);" class="AXTab on" value="Process"><spring:message code='Cache.tte_ProcessListBox'/></a> <!--진행함-->
					<a id="aCompletePage" onclick="clickTab(this);" class="AXTab" value="Complete"><spring:message code='Cache.tte_CompleteListBox'/></a> <!--완료함-->
				</div>
			</div>
			<div class="btn_group bizdoc_wrap">
				<a onclick="bizdocExcelDownLoad();" class="btnTypeDefault btnExcel"><spring:message code='Cache.btn_SaveToExcel' /></a><!-- 엑셀저장 -->
			
				<div class="fRight">
					<select id="selectPageSize" class="selectType02 listCount" style="width: 62px; height: 33px; margin-right: 5px;">
						<option value="10">10</option>
						<option value="20">20</option>
						<option value="30">30</option>
					</select>
					<div class="selBox" style="min-width: 100px; margin-right: 5px;" id="selectGroupType"></div>
					<a class="btnListView listViewType01 active" onclick="onClickListView(this);" value="listView" id="listView" ></a>
					<a class="btnListView listViewType03" onclick="onClickListView(this);" value="beforeView" id="beforeView"></a>
					<button class="btnRefresh" onclick="TabRefresh();"></button><!-- 새로고침 -->
				</div>
			</div>
			<!-- 상단 버튼 영역 끝 -->
			<%
				if(cookie.equals("Y")){
			%>
			<div class="searchBox" style='display: none; margin-top: 10px;' id="groupLiestDiv">
				<div class="searchInner">
					<ul class="usaBox" id='groupLiestArea' style="min-height: 15px;"></ul>
				</div>
			</div>
			<div class="appRelBox">
				<div class="contbox"> <!-- 상단 영역 확장시 값 변경 (기본 125px;) -->
					<!-- 컨텐츠 좌측 시작 -->
					<div class="conin_list ovscroll_x">
						<div id="ListGrid"></div>
					</div>
					<!-- 컨텐츠 좌측 끝 -->
					<!-- 컨텐츠 우측 시작 -->
					<div class="conin_view" id="conin_view"><!-- 좌우 폭 조정에 따라 값 변경(좌측 width값) -->
					<!-- 좌우폭 조정 Bar시작 -->
						<div class="xbar" id="changeScroll" style="top:0px;"></div>
						<div id="IframeDiv" style="display: none;">
							<iframe id="Iframe" name="Iframe" frameborder="0" width="100%" height="770px" class="wordLayout" scrolling="no"></iframe>
						</div>
						<div class="rightFixed" id="contDiv">
							<spring:message code='Cache.msg_approval_clickSubject' />  <!--제목을 클릭해주세요.  -->
						</div>
					</div>
					<!-- 컨텐츠 우측 끝 -->
				</div>
			</div>
			<!-- 그룹별 목록 표시 -->
			<%
				}else{
			%>
			<div class="searchBox" style='display: none; margin-top: 10px;' id="groupLiestDiv">
				<div class="searchInner">
					<ul class="usaBox" id='groupLiestArea' style="min-height: 15px;"></ul>
				</div>
			</div>
			<div class="appRelBox">
				<div class="contbox" > <!-- 상단 영역 확장시 값 변경 (기본 125px;) -->
					<div class="conin_list w100">
						<div id="ListGrid"></div>
					</div>
				</div>
			</div>
			<%
				}
			%>
			<input type="hidden" id="hiddenGroupWord" value="" />
		</div>
	</div>
</div>
<form id="schFrm" style="visibility:hidden" action="" method="post">
	<input type="hidden" id="schFrmSeBizID" name="schFrmSeBizID" value=""/>
	<input type="hidden" id="schFrmSeBizNm" name="schFrmSeBizNm" value=""/>
	<input type="hidden" id="schFrmSeSearchID" name="schFrmSeSearchID" value=""/>
	<input type="hidden" id="schFrmSearchInput" name="schFrmSearchInput" value=""/>
	<input type="hidden" id="schFrmSeGroupID" name="schFrmSeGroupID" value=""/>
	<input type="hidden" id="schFrmSeGroupWord" name="schFrmSeGroupWord" value=""/>
	<input type="hidden" id="schFrmTabId" name="schFrmTabId" value=""/>
</form>
<script>
	var viewsrchTop;
	var srchTop;
	var approvalListType = "bizDoc";				//공통 사용변수: 결재함 종류 표현 - 업무문서함
	var selectParams;									//공통 : 목록 조회시 paramerter 값을 저장
	var headerData;										//공통에서 헤더 정보를 가져오기 위한 변수
	var gridCount = 0;									// gridCount 라는 변수는 각 함에서 동일하게 사용
	var bstored = "false";

	var ListGrid = new coviGrid();
	var clickedTab;
	var g_mode;
	var min = 550;
	var max = 1700;
	var right_min = 100;
	var groupUrl;
	var bizHtml;
	var prevClickIdx  = -1; ///// 결재 상세정보 표시하기 위해 필요한 플래그. 다른 행을 클릭했는지 동일한 행을 토글하기 위해 클릭했는지 판단할때 사용됨
    AXConfig.AXGrid.fitToWidthRightMargin = -1;

	var schFrmSeBizID = "<%=schFrmSeBizID%>";
	var schFrmSeBizNm = "<%=schFrmSeBizNm%>";
	var schFrmSeSearchID = "<%=schFrmSeSearchID%>";
	var schFrmSearchInput = "<%=schFrmSearchInput%>";
	var schFrmSeGroupID = "<%=schFrmSeGroupID%>";
	var schFrmSeGroupWord = "<%=schFrmSeGroupWord%>";
	var schFrmTabId = "<%=schFrmTabId%>";
	
	var selBizList = new Array();		// 업무문서함 SelectBox
	var fnObj1 = {
		pageStart: function(){
			var html = "";
			var len = selBizList.length;
			if (len > 0) {
				if (schFrmSeBizID == "") {
					html = "<span class=\"selTit\" style=\"padding-right:16px\"><a id=\"seBizID\" onclick=\"clickBizSelectBox(this);\" value=\""+selBizList[0].code+"\" class=\"up\">"+CFN_GetDicInfo(selBizList[0].name)+"</a></span>"
				} else {
					html = "<span class=\"selTit\" style=\"padding-right:16px\"><a id=\"seBizID\" onclick=\"clickBizSelectBox(this);\" value=\""+schFrmSeBizID+"\" class=\"up\">"+CFN_GetDicInfo(schFrmSeBizNm)+"</a></span>"
				}
				html += "<div class=\"selList\" style=\"min-width:184px;display: none;\">";
				$(selBizList).each(function(i) {
					if (schFrmSeBizID == selBizList[i].code) {
						html += "<a class=\"listTxt select\" style=\"padding-right:24px\" value=\""+selBizList[i].code+"\" onclick=\"clickBizSelectBoxList(this);\" id=\""+selBizList[i].code+"\">"+CFN_GetDicInfo(selBizList[i].name)+"</a>"
					} else {
						html += "<a class=\"listTxt\" style=\"padding-right:24px\" value=\""+selBizList[i].code+"\" onclick=\"clickBizSelectBoxList(this);\" id=\""+selBizList[i].code+"\">"+CFN_GetDicInfo(selBizList[i].name)+"</a>"
					}
				});
				html += "</div>";	
			}
			
			$("#bizDocSelectBox").html(html);
		}
	};

	//일괄 호출 처리
	initApprovalListComm(initBizDocList, setGrid);
	
	function initBizDocList() {
		window.onresize = function(event) {
			$(".contbox").css('top', $(".content").height());
		};
		
 	<%
		if(!cookie.equals("N")){
	%>
		var cWidth = "<%=listChangeVal%>";
        $('.conin_list').css('width', cWidth);
        $('.conin_view').css('left', cWidth+'px');
		$("#beforeView").addClass("active");
		$("#listView").removeClass("active");
		//setDivision();
	<%
		}else{
	%>
		$("#listView").addClass("active");
		$("#beforeView").removeClass("active");
	<%
		}
	%>
	
		getBizList();
		checkAuthority(); //업무문서함 접근권한 체크
		
		if (schFrmTabId == "") {
			clickTab($("#aProcessPage"));	
		} else {
			clickTab($("#"+schFrmTabId));	
		}
		
		setDivision();
		setSearchParam();	// 이전 검색조건 세팅		
	};

	// 담당업무명 SelectBox DataList
	function getBizList(){
		$.ajax({
			url:"/approval/user/getBizDocListData.do",
			type:"post",
			async:false,
			success:function (data) {
				$(data.list).each(function(index){
					var biz = new Object();
					biz.code = this.BizDocCode;
					biz.name = this.BizDocName;
					selBizList.push(biz);
				});
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/approval/user/getBizDocListData.do", response, status, error);
			}
		});
	}
	
	// 이전 검색조건 세팅
	function setSearchParam() {
		//if (schFrmSeBizID != "") {$('#'+schFrmSeBizID).click();$("#seBizID").click();}
   		if (schFrmSeSearchID != "") {$('#sch_'+schFrmSeSearchID).click();$("#seSearchID").click();}
 		if (schFrmSearchInput != "") {$("#searchInput").val(schFrmSearchInput);}
 		if (schFrmSeGroupID != "") {$('#grp_'+schFrmSeGroupID).click();$("#seGroupID").click();}

 		schFrmSeBizID = "";
 		schFrmSeBizNm = "";
 		schFrmSeSearchID = "";
 		schFrmSearchInput = "";
 		schFrmSeGroupID = "";
 		schFrmSeGroupWord = "";
	}
	
	// 새로고침
	function TabRefresh(){
		$('.AXTab.on').click();
	}

	//업무문서함 접근권한 체크
	function checkAuthority(){
		$.ajax({
			type:"POST",
			url:"/approval/user/getBizDocCount.do",
			async: false,
			success:function (data) {
				if(data.result=="ok"){
					if(data.cnt<=0){
						//다국어: 목록 조회권한이 없습니다.
						Common.Inform("<spring:message code='Cache.msg_NotPermissionListView' />","",function(){
							history.go(-1); //뒤로가기
						});
					}
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/approval/user/getBizDocCount.do", response, status, error);
			}
		});
	}

	function setDivision(){
		$(".conin_list").append("<div id='over'></div>");
	    var pan1 = $('.conin_list');
	    var pan2 = $('.conin_view');
	    var bar =  $('#changeScroll');
	    var frame = $("#Iframe"); //뷰 아이프레임 선언
	    var over = $('#over');
	    var curr_width = pan1.width();
	    var unlock = false;
		$(document).mousemove(function (e) {
			//e.preventDefault();
	        if (unlock) {
		        var change = event.pageX - pan1.offset().left;
	        	if (change > min && change < max && event.pageX < $(window).width() - right_min) {
	        		pan1.css('width', change);
	                pan2.css('left', change);
	                //ListGrid.windowResizeApply(); //스크롤바를 리드로우한다.
	                
	        		CFN_SetCookieDay("ListChangeVal", change, null); // 쿠키저장
	        	}
	        }
	    });
		bar.mouseup(function (e) {
		    ListGrid.windowResizeApply();
		});
	    bar.mousedown(function (e) {
	        curr_width = pan1.width();
	        unlock = true;
		over.css("visibility","visible");
		frame.css("pointer-events","none");
	    });
	    $(document).mousedown(function (e) {
	        if (unlock) {
	            e.preventDefault();
	        }
	    });
	    $(document).mouseup(function (e) {
	    	if(unlock) {
	    	    ListGrid.windowResizeApply(); 
	    	 }
	        unlock = false;
			over.css("visibility","hidden");
			frame.css("pointer-events", "");
	    });
	}

	//탭 선택(그리드 헤더 변경)
	function clickTab(pObj){
		ListGrid = new coviGrid();
		
		// 탭 이동시에는 옵션 새로 그리지 않음.
		if($("#bizDocSelectBox").html() == "")
			fnObj1.pageStart();
		
		$("#divTabTray .AXTab").attr("class","AXTab");
		$(pObj).addClass("AXTab on");

		// IframeDiv 초기화
		//if ($('#Iframe').contents().find('body').html() != "") {
		if (CFN_GetCookie("ListViewCookie") == "Y") {
			var html = "<div id='IframeDiv' style='display: none;'>";
			html += "<iframe id='Iframe' name='Iframe' frameborder='0' width='100%' height='100%' class='wordLayout' scrolling='no'>";
			html += "</iframe></div>";
			$('#IframeDiv').replaceWith(html);
		}
		
		clickedTab = $(pObj).attr("value");
		
		groupUrl = "/approval/user/getBizDocGroupList.do?clickTab="+clickedTab;
		setSelect(ListGrid, "bizDoc", "/approval/user/getBizDocGroupList.do?clickTab="+clickedTab);				// 공통함수 검색조건 select box 바인딩
		$("#searchInput").val("");
		$("#hiddenGroupWord").val("");
		//$("#groupLiestArea").css("display","none");
		$("#groupLiestDiv").css("display","none");
		$(".contbox").css('top', $(".content").height());

		//탭선택에 따른 그리드  변경을 위해 setGrid()호출
		setGrid();
	}

	function clickBizSelectBox(pObj){
		if($(pObj).parent().parent().find('.selList').css('display') == 'none'){
			$(pObj).parent().parent().find('.selList').show();
		}else{
			$(pObj).parent().parent().find('.selList').hide();
		}
		if($(pObj).attr('class')=='listTxt'||$(pObj).attr('class')=='listTxt select'){
			$(pObj).parent().find(".listTxt").attr("class","listTxt");
			$(pObj).attr("class","listTxt select");
			$(pObj).parent().parent().find(".up").html($(pObj).text());
			$(pObj).parent().parent().find(".up").attr("value",$(pObj).attr("value"));
		}
	}

	function clickBizSelectBoxList(pObj){
		var searchGroupType = null;
		var searchGroupWord = null;
		//
		if($(pObj).parent().parent().find('.selList').css('display') == 'none'){
			$(pObj).parent().parent().find('.selList').show();
		}else{
			$(pObj).parent().parent().find('.selList').hide();
		}
		if($(pObj).attr('class')=='listTxt'||$(pObj).attr('class')=='listTxt select'){
			$(pObj).parent().find(".listTxt").attr("class","listTxt");
			$(pObj).parent().parent().find(".up").html($(pObj).text());
			$(pObj).parent().parent().find(".up").attr("value",$(pObj).attr("value"));
		}
		//
		//$('.AXTab.on').click();
		
		setGrid();
	}

	function setGrid(){
		setGridHeader();
		setGridConfig();
		setApprovalListData();
	}

	function setGridConfig(){
		var overflowCell = [];
		//var height = "511px";
		var tabId = $('.AXTab.on').attr('id');
		if (tabId == "aProcessPage") {
			overflowCell = [6];
		} else {
			overflowCell = [5];
		}
		
		var notFixedWidth = -1;
		if ($('.AXTab.on').attr('id') == "aProcessPage") {
			notFixedWidth = 3;
		} else {
			notFixedWidth = 2;
		}
	
		var configObj = {
				targetID : "ListGrid",
				height:"auto",
				//height:height,
				listCountMSG:"<b>{listCount}</b> 개",
				 body: {
						/// 결재 상세정보 표시하기 위해 추가함 ////
 						marker       :
						{
							display: function () { return this.item.showInfo; },
							rows: [
								[{
									colSeq  : null, colspan: 12, formatter: function () {
										$.Event(event).stopPropagation();
											return "<iframe src='/approval/user/ApprovalDetailList.do?FormInstID=" + this.item.FormInstID + "&ProcessID=" + this.item.ProcessID + "' width=100% height=240px frameborder=0>" + this.item.no + "</iframe>" ;
									}, align: "center"

								}]
							]
						}
						///////////////////////////////////////////
	             },
				page : {
					pageNo:1,
					pageSize:$("#selectPageSize").val()
				},
				paging : true,
				notFixedWidth : 3,
				overflowCell : overflowCell
			};

		ListGrid.setGridConfig(configObj);
	}

	function setGridHeader(){
		// 진행함
		 var headerData1 =[
    					  {
        						display: false,
        						key: 'showInfo', label: '' , width: '1', align: 'center'
        				   },
		                  {key:'SubKind', label:'<spring:message code="Cache.lbl_apv_gubun"/>', width:'50', align:'center',sort:false,							// 구분
 		                	  formatter: function () {
		                		   return "<a onclick=\'showDetailInfo(\""+this.index+"\");return false;'>"+this.item.SubKind+"</a>";
							   }
					      },
					      {key:'ApprovalStep', label:'<spring:message code="Cache.lbl_apv_step"/>', width:'70', align:'center',sort:false},						// 결재단계
		                  {key:'FormSubject', label:'<spring:message code="Cache.lbl_apv_subject"/>', width:'200', align:'left',						// 제목
						   	  formatter:function () {
							   		  
							   		var html = "<div>";
						   		    
						   			if(this.item.Priority  == "5"){	html += "<span class=\"btn_emer\">긴급</span>";	}
						   			
						   			if(CFN_GetCookie("ListViewCookie") == "Y"){
						   				html +="<a href='#' onclick='onClickIframeButton(\""+ this.item.ProcessID +"\",\""+this.item.BusinessData1+"\",\""+this.item.BusinessData2+"\"); return false;'>"+this.item.FormSubject+"</a>";	
						   			}else{
						   				html +="<a href='#' onclick='onClickPopButton(\""+ this.item.ProcessID +"\",\""+this.item.FormPrefix+"\",\""+this.item.FormID+"\",\""+this.item.BusinessData1+"\",\""+this.item.BusinessData2+"\"); return false;'>"+this.item.FormSubject+"</a>";
						   			}
						   			
						   			if(this.item.IsSecureDoc == "Y"){	html+= "<span class=\"security\"><spring:message code='Cache.lbl_apv_AuthoritySetting'/></span>";	} //보안
						   			//if(this.item.IsReserved =="Y"){	html += "<span class=\"btn_emer\"><spring:message code='Cache.lbl_apv_hold'/></span>";	} //보류
						   			
						   			html += "</div>";
									
						   			return html;						   		  
								}
		                  },
		                  {key:'InitiatorName',  label:'<spring:message code="Cache.lbl_apv_writer"/>', width:'55', align:'center',
		                	  formatter:function(){
		                		  return setUserFlowerName(this.item.InitiatorID, this.item.InitiatorName);
		                	  }
		                  },						// 기안
		                  {key:'InitiatorUnitName',  label:'<spring:message code="Cache.lbl_DraftDept"/>', width:'70', align:'center', 
		                	  formatter:function(){return this.item.InitiatorUnitName;}
		                  },				// 기안부서
		                  {key:'IsFile', label:'<spring:message code="Cache.lbl_File"/>', width:'50', align:'center',
		                	  formatter:function () {
		                		  if(this.item.IsFile == "Y"){
		                			  return "<div class=\"fClip\" style=\"float: none;\"><a class=\"mClip\" onclick='openFileList(this,\""+this.item.FormInstID+"\")'><spring:message code='Cache.lbl_attach'/></a></div>";//첨부
		                		  }
		                	  }
		                  },	//FileExt								// 파일
		                  {key:'FormName',  label:'<spring:message code="Cache.lbl_FormNm"/>', width:'100', align:'center',
		                	  formatter:function () {
		                		  return CFN_GetDicInfo(this.item.FormName);
	                	  	}},							// 양식명
		                  {key:'StartDate', label:'<spring:message code="Cache.lbl_RepeateDate"/>' + Common.getSession("UR_TimeZoneDisplay"),  width:'100', align:'center', sort:'desc',
		                	  formatter:function () {
	                			  return getStringDateToString("yyyy.MM.dd HH:mm",this.item.StartDate);
	                	  	   }
		                  }]; 		// 일시


		 //완료함
	     var headerData2 =[
    					  {
        						display: false,
        						key: 'showInfo', label: '' , width: '1', align: 'center'
        				   },
	                      {key:'SubKind', label:'<spring:message code="Cache.lbl_apv_gubun"/>', width:'45', align:'center',sort:false,								// 구분
 		                	  formatter: function () {
		                		   return "<a href=\"#none\" onclick=\'showDetailInfo(\""+this.index+"\");return false;'>"+this.item.SubKind+"</a>";
							   }
					      },
		                  {key:'FormSubject', label:'<spring:message code="Cache.lbl_apv_subject"/>', width:'100', align:'left',						// 제목
						   	  formatter:function () {
							   		var html = "<div>";
						   		    
						   			//if(this.item.Priority  == "5"){	html += "<span class=\"btn_emer\"><spring:message code='Cache.lbl_apv_surveyUrgency'/></span>";	} //긴급
						   			
						   			if(CFN_GetCookie("ListViewCookie") == "Y"){
						   				html +="<a href='#' onclick='onClickIframeButton(\""+ this.item.ProcessID +"\",\""+this.item.BusinessData1+"\",\""+this.item.BusinessData2+"\"); return false;'>"+this.item.FormSubject+"</a>";	
						   			}else{
						   				html +="<a href='#' onclick='onClickPopButton(\""+ this.item.ProcessID +"\",\""+this.item.FormPrefix+"\",\""+this.item.FormID+"\",\""+this.item.BusinessData1+"\",\""+this.item.BusinessData2+"\"); return false;'>"+this.item.FormSubject+"</a>";
						   			}
						   			
						   			if(this.item.IsSecureDoc == "Y"){	html+= "<span class=\"security\"><spring:message code='Cache.lbl_apv_AuthoritySetting'/></span>";	} //보안
						   			//if(this.item.IsReserved =="Y"){	html += "<span class=\"btn_emer\"><spring:message code='Cache.lbl_apv_hold'/></span>";	} //보류
						   			
						   			html += "</div>";
									
						   			return html;						   		  
								}
		                  },
		                  {key:'InitiatorName',  label:'<spring:message code="Cache.lbl_apv_writer"/>', width:'55', align:'center',
		                	  formatter:function(){
		                		  return setUserFlowerName(this.item.InitiatorID, this.item.InitiatorName);
		                	  }
		                  },						// 기안자
		                  {key:'InitiatorUnitName',  label:'<spring:message code="Cache.lbl_DraftDept"/>', width:'55', align:'center',
		                	  formatter:function(){return this.item.InitiatorUnitName;}
		                  },				// 기안부서
		                  {key:'IsFile', label:'<spring:message code="Cache.lbl_File"/>', width:'30', align:'center',sort:false,
		                	  formatter:function () {
		                		  if(this.item.IsFile == "Y"){
		                			  return "<div class=\"fClip\" style=\"float: none;\"><a class=\"mClip\" onclick='openFileList(this,\""+this.item.FormInstID+"\")'><spring:message code='Cache.lbl_attach'/></a></div>"; 첨부
		                		  }
		                	  }
		                  },	//FileExt								// 파일
		                  {key:'FormName',  label:'<spring:message code="Cache.lbl_FormNm"/>', width:'50', align:'center',
		                	  formatter:function () {
		                		  return CFN_GetDicInfo(this.item.FormName);
	                	  	}},							// 양식명
		                  {key:'DocNo',  label:'<spring:message code="Cache.lbl_DocNo"/>', width:'50', align:'center'},        //문서번호
		                  {key:'EndDate', label:'<spring:message code="Cache.lbl_RepeateDate"/>' + Common.getSession("UR_TimeZoneDisplay"),  width:'60', align:'center', sort:'desc',
		                	  formatter:function () {
	                			  return getStringDateToString("yyyy.MM.dd HH:mm",this.item.EndDate);
	                	  	   }
		                  }];			// 일시

		if(clickedTab=="Process"){
			headerData = headerData1;
			ListGrid.setGridHeader(headerData1);
		}else if(clickedTab=="Complete"){
			headerData = headerData2;
			ListGrid.setGridHeader(headerData2);
		}
	}

 	/// 결재 상세정보 표시하기 위해 추가함 ////
    function showDetailInfo(index) {
        $.Event(event).stopPropagation();

		var item = ListGrid.list[index];
		if(prevClickIdx != index){ //현재 그리드에서 펼쳐진 행은 모두 닫는다.
			$.each(
					ListGrid.list, function(idx) {
				if(ListGrid.list[idx].showInfo)
					ListGrid.updateItem(0,0,idx,false);
			});
		}
		if(!item.showInfo){
			ListGrid.updateItem(0,0,index,true);
			prevClickIdx = index;
		}
		else{
			ListGrid.updateItem(0,0,index,false);
		}
		ListGrid.setFocus(index);
		ListGrid.windowResizeApply(); //스크롤바를 리드로우한다.
		/* $('#ListGrid_AX_col_AX_2_AX_CB').css('width', '100px');
        $('#ListGrid_AX_col_AX_2_AX_CH').css('width', '100px'); */
    }

	// 목록변경
	function onClickListView(pObj){
		CFN_SetCookieDay("CookieUserID", Common.getSession("USERID"), null); // 쿠키저장
		if($(pObj).attr("value") == "listView"){
			CFN_SetCookieDay("ListViewCookie", "N", null); // 쿠키저장
		}else{
			CFN_SetCookieDay("ListViewCookie", "Y", null); //쿠키저장
		}

		// 이전 검색 조건 세팅
		$('#schFrmSeBizID').val($('#seBizID').attr('value'));
		$('#schFrmSeBizNm').val($('#seBizID').html());
		$('#schFrmSeSearchID').val($('#seSearchID').attr('value'));
		$('#schFrmSearchInput').val($("#searchInput").val());
		$('#schFrmSeGroupID').val($('#seGroupID').attr('value'));
		$('#schFrmSeGroupWord').val($("#hiddenGroupWord").val());
		$('#schFrmTabId').val($('.AXTab.on').attr('id'));
		$("#schFrm").attr("action", "/approval/layout/approval_BizDocList.do?CLSYS=approval&CLMD=user&CLBIZ=Approval");
		$('#schFrm').submit();
		
		//Refresh();		
	}

	function openFileList(pObj,FormInstID){
		if(!axf.isEmpty($(pObj).parent().find('.file_box').html())){
			$(pObj).parent().find('.file_box').remove();
			return false;
		}
		$('.file_box').remove();
		var Params = {
				FormInstID : FormInstID
		};
		$.ajax({
			url:"/approval/getCommFileListData.do",
			type:"post",
			data:Params,
			async:false,
			success:function (data) {
				if(data.list.length > 0){
					var vHtml = "<ul class='file_box'>";
						vHtml += "<li class='boxPoint'></li>";
					for(var i=0; i<data.list.length;i++){
						vHtml += "<li><a onclick='Common.fileDownLoad(\""+data.list[i].FileID+"\",\""+data.list[i].FileName+"\",\""+data.list[i].FileToken+"\"); '>"+data.list[i].FileName+"</a></li>";
					}
					vHtml += "</ul>";
					$(pObj).parent().append(vHtml);
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/approval/getCommFileListData.do", response, status, error);
			}
		});
	}

	function setApprovalListData(){
		var url;
		if(clickedTab == "Process"){
			url = "/approval/user/getBizDocProcessListData.do";
		}else{
			url = "/approval/user/getBizDocCompleteListData.do";
		};
		if(searchValueValidationCheck()){		// 공통 함수
			setSelectParams(ListGrid);
			ListGrid.bindGrid({
				ajaxUrl: url,
				ajaxPars: selectParams,
				onLoad: function(){
					$('.gridBodyTable > tbody > tr > td').css('background', 'white');
					$('.AXGrid').css('overflow','visible');
					if(clickedTab=="Process" || clickedTab=="Complete"){
						$('.btnFlowerName').parent().css('overflow','visible');
					}
					//$('.AXGridBody').css('overflow','visible');
					//$('.AXgridScrollBody').css('overflow','visible');
/*					$('.bodyNode.bodyTdText').css('overflow','visible');*/
					setGridCount();
				}
			});
		}
	}
	function onClickPopButton(ProcessID,FormPrefix,FormID,BusinessData1,BusinessData2){
		var width;
		var archived = null;
		var mode	 = null;
		switch (clickedTab){
			case "Process" : mode="PROCESS"; archived = "false";  break; // 진행함
			case "Complete" : mode="COMPLETE"; archived = "true";  break;    // 완료함
		}
		if(IsWideOpenFormCheck(FormPrefix,FormID) == true){
			width = 1070;
		}else{
			width = 790;
		}
		CFN_OpenWindow("/approval/approval_Form.do?mode="+mode+"&processID="+ProcessID
				+"&workitemID=&performerID=&userCode=&gloct=BizDoc&admintype=&archived="+archived
				+"&usisdocmanager=true&subkind=T006"
				+"&ExpAppID="+((typeof BusinessData2!="undefined"&&BusinessData2!="undefined")?BusinessData2:"")
				, "", width, (window.screen.height - 100), "resize");
	}
	function onClickSearchButton(){
		if($("#seSearchID").attr("value") !="" && $("#searchInput").val() ==""){
			Common.Warning("<spring:message code='Cache.msg_EnterSearchword' />");							//검색어를 입력하세요
			$("#searchInput").focus();
			return false;
		}
		ListGrid.page.pageNo = 1;				// 조회기능 사용시 페이지 초기화
		setGroupType(ListGrid, "/approval/user/getBizDocGroupList.do?clickTab="+clickedTab);			// 공통함수. 그룹별 보기 목록 다시 조회함.
		//setApprovalListData();
		
		// 그룹별 보기 이후에 검색하는 경우 다시 선택할 수 있도록 조회결과 표시하지 않도록 수정
		if($("#seGroupID").attr("value") != "all") {
			ListGrid.bindGrid({page:{pageNo:1,pageSize:$("#selectPageSize").val(),pageCount:1},list:[]});
		}
		
		// 검색어 저장
		coviCtrl.insertSearchData($("#searchInput").val(), 'Approval');
	}

	function setGridCount(){
		gridCount = ListGrid.page.listCount;
		//$("#approvalCnt").html(gridCount);
	}


	function setSearchGroupWord(id){														// 공통함수에서 호출
		ListGrid.page.pageNo = 1;				// 조회기능 사용시 페이지 초기화
		
		$("#hiddenGroupWord").val(id);
		schFrmSeGroupWord = id;
		
		// 클릭 시, hover 와 동일한 css 적용되도록 추가
		$("a[id^='fieldName_']").attr("style", "");
		$("a[id='fieldName_" + id + "']").css("background", "#4497dc");
		$("a[id='fieldName_" + id + "']").css("color", "#fff");
		
		setApprovalListData();
	}

	function onClickIframeButton(ProcessID,BusinessData1,BusinessData2){
		var archived = null;
		var mode	 = null;
		switch (clickedTab){
			case "Process" : mode="PROCESS"; archived = "false";  break; // 진행함
			case "Complete" : mode="COMPLETE"; archived = "true";  break;    // 완료함
		}
		document.IframeFrom.target = "Iframe";
	  	document.IframeFrom.action = "/approval/user/ApprovalIframeList.do";
	  	//
	  	document.IframeFrom.ProcessID.value = ProcessID;
	  	document.IframeFrom.WorkItemID.value = "";
	  	document.IframeFrom.PerformerID.value = "";
	  	document.IframeFrom.ProcessDescriptionID.value = "";
	  	document.IframeFrom.Subkind.value = "T006";
	  	document.IframeFrom.FormTempInstBoxID.value = "";
	  	document.IframeFrom.FormInstID.value = "";
	  	document.IframeFrom.FormID.value = "";
	  	document.IframeFrom.FormInstTableName.value = "";
	  	document.IframeFrom.Mode.value = mode;
	  	document.IframeFrom.Gloct.value = "";
	  	document.IframeFrom.UserCode.value = "";
	  	document.IframeFrom.Archived.value = archived;
	  	document.IframeFrom.BusinessData1.value = BusinessData1;
	  	document.IframeFrom.BusinessData2.value = BusinessData2;
	  	//
	  	document.IframeFrom.submit();
	  	$("#IframeDiv").show();
	  	$("#contDiv").hide();
	}

	function bizdocExcelDownLoad(){
		g_mode = "BIZDOC" + clickedTab.toUpperCase();
		ExcelDownLoad(selectParams, getHeaderDataForExcel(), gridCount);
	}

	
</script>