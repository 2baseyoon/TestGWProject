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
	String schFrmSeGroupID = request.getParameter("schFrmSeGroupID") == null ? "" : request.getParameter("schFrmSeGroupID");
	String schFrmSeGroupWord = request.getParameter("schFrmSeGroupWord") == null ? "" : request.getParameter("schFrmSeGroupWord");
	String schFrmDeptID = request.getParameter("schFrmDeptID") == null ? "" : request.getParameter("schFrmDeptID");
	String schFrmLowDept = request.getParameter("schFrmLowDept") == null ? "" : request.getParameter("schFrmLowDept");
	String schFrmSeSearchID = request.getParameter("schFrmSeSearchID") == null ? "" : request.getParameter("schFrmSeSearchID");
	String schFrmSearchInput = request.getParameter("schFrmSearchInput") == null ? "" : request.getParameter("schFrmSearchInput");
	
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
</form>
<div class="cRConTop titType">
	<h2 class="title"><spring:message code='Cache.MN_504'/></h2><!-- 감사함 -->
	<div class="searchBox02">
		<div class="selBox" style="width: 100px;" id="selectSearchType"></div>
		<span><input type="text" class="sm" id="searchInput"><button type="button" onclick="onClickSearchButton(this);" class="btnSearchType01"><spring:message code='Cache.lbl_search'/> <!--검색--></button></span>
	</div>
</div>
<div class="cRContBottom mScrollVH ">
	<div class="apprvalContent">
		<div class="boradTopCont apprvalTopCont">
			<div class="btn_group Audit_wrap">
				<div class="selBox" style="min-width: 95px;" id="selectGroupType"></div>
				<dl class="radioBtn">
					<dt><a onclick="OrgMap_Open(0);"><spring:message code='Cache.btn_apv_deptselect' /></a></dt>
					<dd><a><input type="checkbox" id="lowDept" name="lowDept" onclick="reloadGroup();"><spring:message code='Cache.lbl_apv_recinfo_td2' /></a></dd>
				</dl>
				<a onclick="ExcelDownLoad(selectParams, getHeaderDataForExcel(), gridCount);"class="btnTypeDefault btnExcel"><spring:message code='Cache.btn_SaveToExcel' /></a><!-- 엑셀저장 -->
			</div>
			<div class="buttonStyleBoxRight">
				<select id="selectPageSize" class="selectType02 listCount">
					<option value="10">10</option>
					<option value="20">20</option>
					<option value="30">30</option>
				</select>
				<a class="btnListView listViewType01 active" onclick="onClickListView(this);" value="listView" id="listView" ></a>
				<a class="btnListView listViewType03" onclick="onClickListView(this);" value="beforeView" id="beforeView"></a>
				<button class="btnRefresh" onclick="Refresh();"></button><!-- 새로고침 -->
			</div>
		</div>
		<div class="apprvalBottomCont">
			<!-- 본문 시작 -->
			<!-- 상단 고정영역 끝 -->
			<%
				if(cookie.equals("Y")){
			%>
			<div class="searchBox" style='display: none' id="groupLiestDiv">
				<div class="searchInner">
					<ul class="usaBox" id='groupLiestArea'></ul>
				</div>
			</div>
			<div class="appRelBox">
				<div class="contbox"> <!-- 상단 영역 확장시 값 변경 (기본 125px;) -->
					<!-- 컨텐츠 좌측 시작 -->
					<div class="conin_list ovscroll_x">
						<div id="auditdeptapprovalListGrid"></div>
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
			<%
				}else{
			%>
			<div class="searchBox" style='display: none' id="groupLiestDiv">
				<div class="searchInner">
					<ul class="usaBox" id='groupLiestArea' ></ul>
				</div>
			</div>
			<div class="appRelBox">
				<div class="contbox"> <!-- 상단 영역 확장시 값 변경 (기본 125px;) -->
					<div class="conin_list w100">
						<div id="auditdeptapprovalListGrid"></div>
					</div>
				</div>
			</div>
			<%
				}
			%>
		</div>
	</div>
</div>
<input type="hidden" id="hiddenGroupWord" value="" />
<input type="hidden" id="checkDeptId" value="" />

<form id="schFrm" style="visibility:hidden" action="" method="post">
	<input type="hidden" id="schFrmSeGroupID" name="schFrmSeGroupID" value=""/>
	<input type="hidden" id="schFrmSeGroupWord" name="schFrmSeGroupWord" value=""/>
	<input type="hidden" id="schFrmDeptID" name="schFrmDeptID" value=""/>
	<input type="hidden" id="schFrmLowDept" name="schFrmLowDept" value=""/>
	<input type="hidden" id="schFrmSeSearchID" name="schFrmSeSearchID" value=""/>
	<input type="hidden" id="schFrmSearchInput" name="schFrmSearchInput" value=""/>
</form>

<script>
	var ListGrid = new coviGrid();		// ListGrid 라는 변수는 각 함에서 동일하게 사용
	var headerData;						// Grid 의 헤더 데이터. 엑셀저장을 위함. JSONObject
	var gridCount = 0;					// gridCount 라는 변수는 각 함에서 동일하게 사용
	var selectParams;					// 그리드 조회 파라미터. 엑셀저장을 위함. JSONObject
	var approvalListType = "auditDept";					// 공통 사용 변수 - 결재함 종류 표현 - 감사문서함
	var min = 550;
	var max = 1700;
	var right_min = 100;
    var prevClickIdx  = -1; ///// 결재 상세정보 표시하기 위해 필요한 플래그. 다른 행을 클릭했는지 동일한 행을 토글하기 위해 클릭했는지 판단할때 사용됨
    var viewsrchTop;
    var srchTop;
    var groupUrl;
    var g_mode = "AuditDept";
    var bstored = "true";
    AXConfig.AXGrid.fitToWidthRightMargin = -1;

	var schFrmSeGroupID = "<%=schFrmSeGroupID%>";
	var schFrmSeGroupWord = "<%=schFrmSeGroupWord%>";
	var schFrmDeptID = "<%=schFrmDeptID%>";
	var schFrmLowDept = "<%=schFrmLowDept%>";
	var schFrmSeSearchID = "<%=schFrmSeSearchID%>";
	var schFrmSearchInput = "<%=schFrmSearchInput%>";

	//일괄 호출 처리
	initApprovalListComm(initAuditList, setGrid);
	
	function initAuditList(){
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
	
		groupUrl = "/approval/getAuditDeptCompleteGroupListData.do";
		setSelect(ListGrid, approvalListType, groupUrl);				// 공통함수
		setGrid();
		$("#searchInput").val("");
		$("#hiddenGroupWord").val("");
		$("#groupLiestDiv").css("display","none");

		setDivision();
		setSearchParam();	// 이전 검색조건 세팅
	}
	
	// 이전 검색조건 세팅
	function setSearchParam() {
 		if (schFrmSeGroupID != "") {$('#grp_'+schFrmSeGroupID).click();$("#seGroupID").click();}
 		if (schFrmLowDept != "" && schFrmLowDept == 1) {$("#lowDept").prop("checked", true);}
 		if (schFrmSeSearchID != "") {$('#sch_'+schFrmSeSearchID).click();$("#seSearchID").click();}
 		if (schFrmSearchInput != "") {$("#searchInput").val(schFrmSearchInput)}
			
		schFrmSeGroupID = "";
		schFrmSeGroupWord = "";
		schFrmDeptID = "";
		schFrmLowDept = "";
		schFrmSeSearchID = "";
		schFrmSearchInput = "";
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

	function setGrid(){
		setGridConfig();
		setApprovalListData();
	}

	function setGridConfig(){
		var notFixedWidth = 2;
		//var height = "511px";
		
		headerData =[{key:'chk', label:'chk', width:'20', align:'center', formatter:'checkbox'},
	                  //{key:'SubKind', label:'<spring:message code="Cache.lbl_apv_gubun"/>', width:'30', align:'center',sort:false},								   // 구분
	                  {key:'FormSubject', label:'<spring:message code="Cache.lbl_apv_subject"/>', width:'200', align:'left',						       // 제목
					   	  formatter:function () {
					   		var html = "";
					   		  
					   		if((CFN_GetCookie("ListViewCookie") == "Y")){
					   			html = "<a href='#' onclick='onClickIframeButton(\""+this.item.ProcessArchiveID+"\",\""+this.item.ProcessDescriptionArchiveID+"\"); return false;'>"+this.item.FormSubject+"</a>";
					   		}else{
					   			html = "<a href='#' onclick='onClickPopButton(\""+this.item.ProcessArchiveID+"\",\""+this.item.ProcessDescriptionArchiveID+"\",\""+this.item.FormPrefix+"\",\""+this.item.FormID+"\"); return false;'>"+this.item.FormSubject+"</a>";
					   		}
					   		
					   		if(this.item.IsSecureDoc == "Y"){	html += "<span class=\"security\"><spring:message code='Cache.lbl_apv_AuthoritySetting'/></span>";	} //보안
					   		
					   		return html;
							}
	                  },
	                  {key:'InitiatorUnitName',  label:'<spring:message code="Cache.lbl_DraftDept"/>', width:'55', align:'center',
	                	  formatter:function(){return this.item.InitiatorUnitName;}
	                  },				           // 기안부서
	                  {key:'InitiatorName',  label:'<spring:message code="Cache.lbl_apv_writer"/>', width:'55', align:'center',
	                	  formatter:function(){return setUserFlowerName(this.item.InitiatorID, this.item.InitiatorName);}
	                  },						   // 기안자
	                  {key:'IsFile', label:'<spring:message code="Cache.lbl_File"/>', width:'30', align:'center',sort:false,
	                	  formatter:function () {
	                		  if(this.item.IsFile == "Y"){
	                			  return "<div class=\"fClip\" style=\"float: none;\"><a class=\"mClip\" onclick='openFileList(this,\""+this.item.FormInstID+"\")'>첨부</a></div>";
	                		  }
	                	  }
	                  },	//FileExt							   // 파일
	                  {key:'FormName',  label:'<spring:message code="Cache.lbl_FormNm"/>', width:'50', align:'center'},								 	   // 양식명
	                  {key:'EndDate', label:'<spring:message code="Cache.lbl_RepeateDate"/>' + Common.getSession("UR_TimeZoneDisplay"),  width:'60', align:'center', sort:'desc',
	                	  formatter:function () {
                			  return getStringDateToString("yyyy.MM.dd HH:mm:ss",this.item.EndDate);
                	  	   }
	                  }];				   // 일시
		ListGrid.setGridHeader(headerData);

		var configObj = {
			targetID : "auditdeptapprovalListGrid",
			height:"auto",
			//height:height,
			listCountMSG:"<b>{listCount}</b> <spring:message code='Cache.lbl_Count'/>",
			page : {
				pageNo:1,
				pageSize:$("#selectPageSize").val()
			},
			paging : true,
			notFixedWidth : notFixedWidth
		};

		ListGrid.setGridConfig(configObj);
	}

	function setApprovalListData(){
		if(searchValueValidationCheck()){		// 공통 함수
			setSelectParams(ListGrid);// 공통 함수
			
			ListGrid.bindGrid({
				ajaxUrl:"/approval/getAuditDeptCompleteListData.do",
				ajaxPars: selectParams,
				onLoad: function(){
					$('.gridBodyTable > tbody > tr > td').css('background', 'white');
					$('.AXGrid').css('overflow','visible');
					setGridCount();
				}
			});
		}
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
		$('#schFrmSeGroupID').val($('#seGroupID').attr('value'));
		$('#schFrmSeGroupWord').val($("#hiddenGroupWord").val());
		$('#schFrmDeptID').val($("#checkDeptId").val());
		if($("#lowDept").prop('checked') == true){
			$('#schFrmLowDept').val(1);
		}else{
			$('#schFrmLowDept').val(0);
		}
		$('#schFrmSeSearchID').val($('#seSearchID').attr('value'));
		$('#schFrmSearchInput').val($("#searchInput").val());
		$("#schFrm").attr("action", "/approval/layout/approval_AuditDeptCompleteList.do?CLSYS=approval&CLMD=user&CLBIZ=Approval");
		$('#schFrm').submit();
	}

	function openFileList(pObj,FormInstID){
		if(!axf.isEmpty($(pObj).parent().find('.file_box').html())){
			$(pObj).parent().find('.file_box').remove();
			return false;
		}
		$('.file_box').remove();
		var Params = {
				FormInstID : FormInstID,
				bstored: bstored
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

	function setGridCount(){
		gridCount = ListGrid.page.listCount;
		$("#approvalCnt").html(gridCount);
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

	function onClickSearchButton(){
		if($("#seSearchID").attr("value") !="" && $("#searchInput").val() ==""){
			Common.Warning("<spring:message code='Cache.msg_EnterSearchword' />");							//검색어를 입력하세요
			$("#searchInput").focus();
			return false;
		}
		
		reloadGroup();
		
		// 검색어 저장
		coviCtrl.insertSearchData($("#searchInput").val(), 'Approval');
	}
	
	// 하위부서, 부서변경시 그룹핑내역도 reload.
	function reloadGroup(){
		ListGrid.bindGrid({
			page:{
				pageNo:1,
				pageSize:$("#selectPageSize").val(),
				pageCount:1
			},
			list:[]
		});
		setGroupType(ListGrid, groupUrl); // ApprovalListCommon.js
	}
	
	function onClickPopButton(ProcessID,ProcessDescriptionID,FormPrefix,FormID){
		var width;
		var mode = null;
		if($("#lowDept").prop('checked') == true){
			mode = 1;
		}else{
			mode = 0;
		}
		if(IsWideOpenFormCheck(FormPrefix, FormID) == true){
			width = 1070;
		}else{
			width = 790;
		}
		CFN_OpenWindow("/approval/approval_Form.do?mode="+mode+"&processID="+ProcessID+"&processdescriptionID="+ProcessDescriptionID+"&gloct=COMPLETE&admintype=&archived=true&bstored=true&usisdocmanager=true", "", width, (window.screen.height - 100), "resize");
	}
	//부서선택 버튼 클릭시 호출될 조직도 팝업.
	function OrgMap_Open(mapflag){
		flag = mapflag;
		//다국어: 조직도
		parent.Common.open("","orgmap_pop","<spring:message code='Cache.lbl_apv_org'/>","/covicore/control/goOrgChart.do?callBackFunc=_CallBackMethod2&type=C1","1000px","580px","iframe",true,null,null,true);
	}
	// 조직도 데이터
	parent._CallBackMethod2 = setOrgMapData;
	function setOrgMapData(data){
		//ListGrid = new coviGrid();
		
		//var dataObj = Object.toJSON(data);
		var dataObj = $.parseJSON(data);
		$("#checkDeptId").val(dataObj.item[0].AN);
		$("#schFrmDeptID").val(dataObj.item[0].AN);
		
		reloadGroup();
	}
	
	function onClickIframeButton(ProcessID,ProcessDescriptionID){
		var mode = null;
		if($("#lowDept").prop('checked') == true){
			mode = 1;
		}else{
			mode = 0;
		}
		document.IframeFrom.target = "Iframe";
	  	document.IframeFrom.action = "/approval/user/ApprovalIframeList.do";
	  	//
	  	document.IframeFrom.ProcessID.value = ProcessID;
	  	document.IframeFrom.WorkItemID.value = "";
	  	document.IframeFrom.PerformerID.value = "";
	  	document.IframeFrom.ProcessDescriptionID.value = ProcessDescriptionID;
	  	document.IframeFrom.Subkind.value = "";
	  	document.IframeFrom.FormTempInstBoxID.value = "";
	  	document.IframeFrom.FormInstID.value = "";
	  	document.IframeFrom.FormID.value = "";
	  	document.IframeFrom.FormInstTableName.value = "";
	  	document.IframeFrom.Mode.value = mode;
	  	document.IframeFrom.Gloct.value = "COMPLETE";
	  	document.IframeFrom.UserCode.value = "";
	  	document.IframeFrom.Archived.value = "true";
	  	document.IframeFrom.bstored.value = "true";
	  	//
	  	document.IframeFrom.submit();
	  	$("#IframeDiv").show();
	  	$("#contDiv").hide();
	}
</script>