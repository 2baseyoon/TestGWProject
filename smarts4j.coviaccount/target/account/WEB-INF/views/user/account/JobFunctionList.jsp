<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@page import="egovframework.baseframework.util.SessionHelper"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%
	String userID 				= SessionHelper.getSession("USERID");
	String useFido			    = PropertiesUtil.getSecurityProperties().getProperty("fido.login.used");
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
	String schFrmJobFunctionId = request.getParameter("schFrmJobFunctionId") == null ? "" : request.getParameter("schFrmJobFunctionId");
	String schFrmJobFunctionNm = request.getParameter("schFrmJobFunctionNm") == null ? "" : request.getParameter("schFrmJobFunctionNm");
	String schFrmSeGroupID = request.getParameter("schFrmSeGroupID") == null ? "" : request.getParameter("schFrmSeGroupID");
	String schFrmSearchInput = request.getParameter("schFrmSearchInput") == null ? "" : request.getParameter("schFrmSearchInput");
	String schFrmSeSearchID = request.getParameter("schFrmSeSearchID") == null ? "" : request.getParameter("schFrmSeSearchID");
	String schFrmSeGroupWord = request.getParameter("schFrmSeGroupWord") == null ? "" : request.getParameter("schFrmSeGroupWord");
	String schFrmTabId = request.getParameter("schFrmTabId") == null ? "" : request.getParameter("schFrmTabId");
	
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<script type="text/javascript" src="/approval/resources/script/user/ApprovalListCommon.js<%=resourceVersion%>"></script>
<style>
	#over {position: absolute; top: 0; left: 0;  width: 100%; height: 100%;  visibility: hidden; z-index: 2; }
	.conin_list {overflow-y:auto};
</style>
<form name="IframeFrom" method="post">
	<input type="hidden" id="ProcessID" 			name="ProcessID" 			value="">
	<input type="hidden" id="WorkItemID" 			name="WorkItemID" 			value="">
	<input type="hidden" id="TaskID" 				name="TaskID" 				value="">
	<input type="hidden" id="PerformerID" 			name="PerformerID" 			value="">
	<input type="hidden" id="ProcessDescriptionID" 	name="ProcessDescriptionID" value="">
	<input type="hidden" id="Subkind" 				name="Subkind" 				value="">
	<input type="hidden" id="FormInstID" 			name="FormInstID" 			value="">
	<input type="hidden" id="UserCode" 				name="UserCode" 			value="">
	<input type="hidden" id="FormPrefix" 			name="FormPrefix" 			value="">
	<input type="hidden" id="BusinessData2" 		name="BusinessData2" 		value="">
	<input type="hidden" id="FormID" 				name="FormID" 				value="">
	<input type="hidden" id="Mode" 					name="Mode" 				value="">
	<input type="hidden" id="Gloct" 				name="Gloct" 				value="">
	<input type="hidden" id="Archived" 				name="Archived" 			value="">
	<input type="hidden" id="Admintype" 			name="Admintype" 			value="">
	<input type="hidden" id="Usisdocmanager" 		name="Usisdocmanager" 		value="true">
	<input type="hidden" id="Listpreview" 			name="Listpreview" 			value="Y">
</form>
<div class="cRConTop titType">
	<h2 class="title" id="headerTitle"></h2>
	<%-- <span class="topstit_n"><spring:message code='Cache.lbl_BizName'/>  : </span> --%>
	<div class="selBox" style="width: 184px; margin-left: 10px;" id="jobFunctionSelectBox"></div>
	<div class="searchBox02">
		<div class="selBox" style="width: 100px;" id="selectSearchType"></div>
		<span><input type="text" class="sm" id="searchInput"  onkeypress="if (event.keyCode==13){ accountCtrl.getInfo('simpleSearchBtn').click(); return false;}" ><button id="simpleSearchBtn"  type="button" onclick="onClickSearchButton_JF(this);" class="btnSearchType01"><spring:message code='Cache.lbl_search'/><!-- 검색 --></button></span>
	</div>
</div>
<div class="cRContBottom mScrollVH ">
	<div class="apprvalContent">
		<div class="apprvalBottomCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<div class="AXTabsLarge">
					<div id="divTabTray" class="AXTabsTray">
						<a id="aApprovalPage" onclick="clickTab(this);" class="AXTab" value="Approval"><spring:message code='Cache.tte_ApprovalListBox'/></a> <!--미결함-->
						<a id="aProcessPage" onclick="clickTab(this);" class="AXTab" value="Process"><spring:message code='Cache.tte_ProcessListBox'/></a> <!--진행함-->
						<a id="aCompletePage" onclick="clickTab(this);" class="AXTab" value="Complete"><spring:message code='Cache.tte_CompleteListBox'/></a> <!--완료함-->
						<a id="aRejectPage" onclick="clickTab(this);" class="AXTab" value="Reject" ><spring:message code='Cache.tte_RejectListBox'/></a> <!--반려함-->
					</div>
				</div>
				<div class="btn_group">
					<a id="btn_blockApproval" onclick="BatchApproval(ListGrid, 'JOBFUNCTION', '<%=useFido%>');"class="btnTypeDefault"><spring:message code='Cache.btn_apv_blocApprove' /></a><!-- 일괄결재 -->
					<a onclick="jobFunctionExcelDownLoad();" class="btnTypeDefault btnExcel"><spring:message code='Cache.btn_SaveToExcel' /></a><!-- 엑셀저장 -->
					<div class="fRight">
						<select id="selectPageSize" class="selectType02 listCount" style="width: 62px; height: 33px; margin-right: 5px;">
							<option value="10">10</option>
							<option value="20">20</option>
							<option value="30">30</option>
						</select>
						<div class="selBox" style="min-width: 95px; margin-right: 5px;" id="selectGroupType"></div>
						<!-- <a class="btnListView listViewType01 active" onclick="onClickListView_JF(this);" value="listView" id="listView" ></a>
						<a class="btnListView listViewType03" onclick="onClickListView_JF(this);" value="beforeView" id="beforeView"></a> -->
						<button class="btnRefresh" onclick="TabRefresh();"></button><!-- 새로고침 -->
					</div>
				</div>
			</div>
			<!-- 그룹별 목록 표시 -->
			<%
				if(cookie.equals("Y")){
			%>
			<div class="searchBox" style='display: none; margin-top: 10px;' id="groupLiestDiv">
				<div class="searchInner">
					<ul class="usaBox" id='groupLiestArea' style='min-height: 15px;'></ul>
				</div>
			</div>
			<div class="appRelBox">
				<div class="contbox" > <!-- 상단 영역 확장시 값 변경 (기본 125px;) -->
					<!-- 컨텐츠 좌측 시작 -->
					<div class="conin_list">
						<div id="JobFunctionListGrid"></div>
					</div>
					<!-- 컨텐츠 좌측 끝 -->
					<!-- 컨텐츠 우측 시작 -->
					<div class="conin_view" id="conin_view"><!-- 좌우 폭 조정에 따라 값 변경(좌측 width값) -->
						<!-- 좌우폭 조정 Bar시작 -->
						<div class="xbar" id="changeScroll" style="top:0px;"></div>
						<div id="IframeDiv" style="display: none;">
							<iframe id="Iframe" name="Iframe" frameborder="0" width="100%" height="770px" class="wordLayout" scrolling="no" title=""></iframe>
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
			<div class="searchBox" style='display: none; margin-top: 10px;' id="groupLiestDiv">
				<div class="searchInner">
					<ul class="usaBox" id='groupLiestArea' style='min-height: 15px;'></ul>
				</div>
			</div>
			<div class="appRelBox">
				<div class="contbox" > <!-- 상단 영역 확장시 값 변경 (기본 125px;) -->
					<div class="conin_list" style="width:100%;">
						<div id="JobFunctionListGrid"></div>
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

<form id="schFrm" style="visibility:hidden" action="" method="post">
	<input type="hidden" id="schFrmJobFunctionId" name="schFrmJobFunctionId" value=""/>
	<input type="hidden" id="schFrmJobFunctionNm" name="schFrmJobFunctionNm" value=""/>
	<input type="hidden" id="schFrmSeSearchID" name="schFrmSeSearchID" value=""/>
	<input type="hidden" id="schFrmSearchInput" name="schFrmSearchInput" value=""/>
	<input type="hidden" id="schFrmSeGroupID" name="schFrmSeGroupID" value=""/>
	<input type="hidden" id="schFrmSeGroupWord" name="schFrmSeGroupWord" value=""/>
	<input type="hidden" id="schFrmTabId" name="schFrmTabId" value=""/>
</form>

<script>
	var approvalListType = "jobFunction"				//공통 사용변수: 결재함 종류 표현 - 담당업무함
	var selectParams;									//공통 : 목록 조회시 paramerter 값을 저장
	var headerData;										//공통에서 헤더 정보를 가져오기 위한 변수
	var gridCount = 0;					// gridCount 라는 변수는 각 함에서 동일하게 사용
	var mode  	= "";
	var gloct 	= "";
	var subkind = "";
	var archived = "";
	var userCode = "";
    var viewsrchTop;
    var srchTop;
	var min = 550;
	var max = 1700;
	var right_min = 100;
	var prevClickIdx  = -1; ///// 결재 상세정보 표시하기 위해 필요한 플래그. 다른 행을 클릭했는지 동일한 행을 토글하기 위해 클릭했는지 판단할때 사용됨
    AXConfig.AXGrid.fitToWidthRightMargin = -1;
	
	var groupUrl = "/approval/user/getJobFunctionGroupList.do?clickTab=Approval"; //공통 사용 변수
	var ListGrid = new coviGrid();
	var clickedTab;
	var g_mode;
	var bstored = "false";
	var jobFunctionSubKind; 							//담당업무함은 구분값이 모두 "담당"이기 때문에 Common.getDic을 한번만 하도록 변수 사용
	var ProfileImagePath = Common.getBaseConfig('ProfileImagePath').replace("{0}", Common.getSession("DN_Code"));
	
	var schFrmJobFunctionId = "<%=schFrmJobFunctionId%>";
	var schFrmJobFunctionNm = "<%=schFrmJobFunctionNm%>";
	var schFrmSeSearchID = "<%=schFrmSeSearchID%>";
	var schFrmSearchInput = "<%=schFrmSearchInput%>";
	var schFrmSeGroupID = "<%=schFrmSeGroupID%>";
	var schFrmSeGroupWord = "<%=schFrmSeGroupWord%>";
	var schFrmTabId = "<%=schFrmTabId%>";
	
	var selFuncList = new Array();		// 담당업무명 SelectBox
	var fnObj1 = {
		pageStart: function() {
			var html = "";
			var len = selFuncList.length;
			if (len > 0) {
				if (schFrmJobFunctionId == "") {
					html = "<span class=\"selTit\" ><a id=\"seFuncId\" onclick=\"clickFuncSelectBox(this);\" value=\""+selFuncList[0].code+"\" class=\"up\">"+CFN_GetDicInfo(selFuncList[0].name)+"</a></span>"
				} else {
					html = "<span class=\"selTit\" ><a id=\"seFuncId\" onclick=\"clickFuncSelectBox(this);\" value=\""+schFrmJobFunctionId+"\" class=\"up\">"+CFN_GetDicInfo(schFrmJobFunctionNm)+"</a></span>"
				}
				html += "<div class=\"selList\" style=\"width:200px;display: none;\">";
				$(selFuncList).each(function(i) {
					if (schFrmJobFunctionId == selFuncList[i].code) {
						html += "<a class=\"listTxt select\" value=\""+selFuncList[i].code+"\" onclick=\"clickFuncSelectBoxList(this);\" id=\""+selFuncList[i].code+"\">"+CFN_GetDicInfo(selFuncList[i].name)+"</a>"
					} else {
						html += "<a class=\"listTxt\" value=\""+selFuncList[i].code+"\" onclick=\"clickFuncSelectBoxList(this);\" id=\""+selFuncList[i].code+"\">"+CFN_GetDicInfo(selFuncList[i].name)+"</a>"
					}
				});
				html += "</div>";	
			}
			
			accountCtrl.getInfo("jobFunctionSelectBox").html(html);
		}
	};
	
	//일괄 호출 처리
	initApprovalListComm(initJobFunction, setGrid);
	
	function initJobFunction() {
		setHeaderTitle('headerTitle');
		
		window.onresize = function(event) {
			accountCtrl.getInfoStr(".contbox").css('top', $(".content").height());
		};
		
		accountCtrl.getInfo("listView").addClass("active");
		accountCtrl.getInfo("beforeView").removeClass("active");
	
		getFuncList();
		checkAuthority(); //담당업무함 접근권한 체크
		
		jobFunctionSubKind = "<spring:message code='Cache.lbl_apv_charge' />";
		
		if (schFrmTabId == "") {
			clickTab(accountCtrl.getInfo("aApprovalPage"));	
		} else {
			clickTab(accountCtrl.getInfo(""+schFrmTabId));
		}
		
		setSearchParam_JF();	// 이전 검색조건 세팅		
	}
	
	// 담당업무명 SelectBox DataList
	function getFuncList(){
		$.ajax({
			url:"/approval/user/getJobFunctionListData.do",
			type:"post",
			data:{
				JobFunctionType:"ACCOUNT"
			},
			async:false,
			success:function (data) {
				$(data.list).each(function(index){
					var func = new Object();
					func.code = this.JobFunctionCode;
					func.name = this.JobFunctionName;
					selFuncList.push(func);
				});
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/approval/user/getJobFunctionListData.do", response, status, error);
			}
		});
	}
	
	// 새로고침
	function TabRefresh(){
		accountCtrl.getInfoStr('.AXTab.on').click();
	}
	
	// 이전 검색조건 세팅
	function setSearchParam_JF() {
  		if (schFrmSeSearchID != "") {accountCtrl.getInfo('sch_'+schFrmSeSearchID).click();accountCtrl.getInfo("seSearchID").click();}
 		if (schFrmSearchInput != "") {accountCtrl.getInfo("searchInput").val(schFrmSearchInput);}
 		if (schFrmSeGroupID != "") {accountCtrl.getInfo('grp_'+schFrmSeGroupID).click();accountCtrl.getInfo("seGroupID").click();}

 		schFrmJobFunctionId = "";
 		schFrmJobFunctionNm = "";
 		schFrmSeSearchID = "";
 		schFrmSearchInput = "";
 		schFrmSeGroupID = "";
 		schFrmSeGroupWord = "";
	}
	
	//담당업무함 접근권한 체크
	function checkAuthority(){
		$.ajax({
			type:"POST",
			url:"/approval/user/getJobFunctionCount.do",
			async: false,
			data:{
				JobFunctionType:"ACCOUNT"
			},
			success:function (data) {
				if(data.result=="ok"){
					if(data.cnt<=0){
						//다국어: 목록 조회권한이 없습니다.
						Common.Inform("<spring:message code='Cache.msg_NotPermissionListView' />","",function(){
							$("#"+nowAjaxID+"TabDiv").find("a[name=tabDivDeleteA]").trigger('click');
						});
					}
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/approval/user/getJobFunctionCount.do", response, status, error);
			}
		});
	}

	//탭 선택(그리드 헤더 변경)
	function clickTab(pObj){
		ListGrid = new coviGrid();
		
		// 탭 이동시에는 옵션 새로 그리지 않음.
		if(accountCtrl.getInfo("jobFunctionSelectBox").html() == "")
			fnObj1.pageStart();
		
		accountCtrl.getInfoStr("#divTabTray .AXTab").attr("class","AXTab");
		$(pObj).addClass("AXTab on");

		clickedTab = $(pObj).attr("value");

		if(clickedTab !="Approval"){
			accountCtrl.getInfo('btn_blockApproval').hide();
		}else {
			accountCtrl.getInfo('btn_blockApproval').show();
		}
		
		groupUrl = "/approval/user/getJobFunctionGroupList.do?&clickTab="+clickedTab;
		setSelect(ListGrid, "jobFunction", "/approval/user/getJobFunctionGroupList.do?&clickTab="+clickedTab);				// 공통함수 검색조건 select box 바인딩
		accountCtrl.getInfo("searchInput").val("");
		accountCtrl.getInfo("hiddenGroupWord").val("");
		accountCtrl.getInfo("groupLiestDiv").css("display","none");
		accountCtrl.getInfoStr(".contbox").css('top', $(".content").height());
		
		//탭선택에 따른 그리드  변경을 위해 setGrid()호출
		setGrid();
	}

	function clickFuncSelectBox(pObj){
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

	function clickFuncSelectBoxList(pObj){
		//
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
		
		setGrid();
	}
	
	function setGrid(){
		setGridHeader_JF();
		setGridConfig_JF();
		setApprovalListData_JF();
	}

	function setGridConfig_JF(){
		var overflowCell = [];
		/* var tabId = $('.AXTab.on').attr('id');
		if (tabId == "aApprovalPage" || tabId == "aProcessPage") {
			overflowCell = [4];
		} else {
			overflowCell = [6];
		} */
		
		var configObj = {
				targetID : "JobFunctionListGrid",
				height:"auto",
				 body: {
						/// 결재 상세정보 표시하기 위해 추가함 ////
						marker       :
						{
							display: function () { return this.item.showInfo; },
							rows: [
								[{
									colSeq  : null, colspan: 12, formatter: function () {
										$.Event(event).stopPropagation();
										if(clickedTab=="Approval" || clickedTab=="Process"){ //미결함||진행함
											return "<iframe src='/approval/user/ApprovalDetailList.do?FormInstID=" + this.item.FormInstID + "&ProcessID=" + this.item.ProcessID + "' width=100% height=240px frameborder=0>" + this.item.no + "</iframe>" ;
										}else if(clickedTab=="Complete" || clickedTab=="Reject"){ //완료함 || 반려함
											return "<iframe src='/approval/user/ApprovalDetailList.do?FormInstID=" + this.item.FormInstID + "&ProcessID=" + this.item.ProcessArchiveID + "' width=100% height=240px frameborder=0>" + this.item.no + "</iframe>" ;
										}
									}, align: "center"

								}]
							]
						}
	             },
				page : {
					pageNo:1,
					pageSize:accountCtrl.getInfo("selectPageSize").val()
				},
				paging : true,
				notFixedWidth : 3,
				overflowCell : overflowCell
			};

		ListGrid.setGridConfig(configObj);
	}

	function setGridHeader_JF(){
		//미결함, 진행함
		 var headerData1 =[
    					  {
      						display: false,
      						key: 'showInfo', label: '' , width: '1', align: 'center'
      					  },
		              	  {key:'chk', label:'chk', width:'25', align:'center', formatter:'checkbox',
      						  disabled : function(){
      							  var isChkConfirm = this.item.ExtInfo;
      							  if(clickedTab=="Approval" && isChkConfirm != undefined){
	      							  var returnStr = true;
	      							  
	      							  if(isChkConfirm != "" && isChkConfirm.UseBlocApprove == "Y")
	      								  returnStr = false;
	      							  
	      							  return returnStr;
      							  }else{
      								  return false;
      							  }
      						 }
		              	  },
		                  {key:'InitiatorName', label:'<spring:message code="Cache.lbl_apv_writer"/>', width:'45', align:'center',sort:false,showExcel:true,
		                	  formatter: function () {
		                		  return "<div class=\"poRela\"><a class=\"cirPro\"><img style=\"max-width: 100%; height: auto;\" src="+coviCmn.loadImage(this.item.PhotoPath)+" alt=\"\" onerror='coviCmn.imgError(this, true)'></a><a class=\"opnBt\" href=\"#\" onclick=\'showDetailInfo_JF(\""+this.index+"\");return false;'></a></div>";
							   }
		              	  },// 기안자
			                  {key:'FormSubject', label:'<spring:message code="Cache.lbl_apv_subject"/>', width:'350', align:'left',showExcel:true,						    // 제목
							   	  formatter:function () {
							   		    var html = "<div>";
							   		     
							   			if(this.item.Priority  == "5"){	html += "<span class=\"btn_emer\"><spring:message code='Cache.lbl_apv_surveyUrgency'/></span>";	}  //긴급
							   			
							   			html += "<a class=\"taTit\" onclick='onClickPopButton_JF(\""+this.item.ProcessID+"\",\""+this.item.WorkItemID+"\",\""+this.item.TaskID+"\",\""+this.item.PerformerID+"\",\""+this.item.ProcessDescriptionID+"\",\""+this.item.FormSubKind+"\",\""+this.item.FormInstID+"\",\""+this.item.BusinessData2+"\"); return false;'>"+this.item.FormSubject+"</a>";
							   			
							   			if(this.item.IsSecureDoc == "Y"){	html+= "<span class=\"security\"><spring:message code='Cache.lbl_apv_AuthoritySetting'/></span>";	} //보안
							   			if(this.item.IsReserved =="Y"){	html += "<span class=\"btn_emer\"><spring:message code='Cache.lbl_apv_hold'/></span>";	} //보류
							   			
							   			var InitiatorName = CFN_GetDicInfo(this.item.InitiatorName);
						   				var SubUserName = InitiatorName;
						   				if(this.item.BusinessData5.indexOf('^^^')>-1)
						   					SubUserName = CFN_GetDicInfo(this.item.BusinessData5.split('^^^')[1]);
						   				InitiatorName = (!SubUserName || SubUserName === "null" || InitiatorName === SubUserName)?InitiatorName:InitiatorName+'('+SubUserName+')';

										// 프리젠트 (FlowerName)
										InitiatorName = "<div class=\"btnFlowerName\" onclick=\"coviCtrl.setFlowerName(this)\" style=\"position:relative; cursor:pointer;\" data-user-code=\""+this.item.InitiatorID+"\" data-user-mail>" + InitiatorName + "</div>";
										
						   				var currentTarget='';
						   				if( clickedTab=="Process"&&this.item.DomainDataContext!=undefined)
						   				{
							   				var oApvList = this.item.DomainDataContext
								   			var oCurrentOUNode = $$(oApvList).find("steps > division:has(>taskinfo[status='pending'])");
								   			var oRecOUNode = $$(oCurrentOUNode).find("step").has("ou>taskinfo[status='pending']");
								   			
								   			if($$(oRecOUNode).find("ou").hasChild("person").length >0) {
								   				var ouPersonName = $$(oRecOUNode).find("ou>person").attr('name');
								   				var ouPersonCode = $$(oRecOUNode).find("ou>person").attr('code');
												// 프리젠트 (FlowerName)
								   				currentTarget	=	"<div class=\"btnFlowerName\" onclick=\"coviCtrl.setFlowerName(this)\" style=\"position:relative; cursor:pointer;\" data-user-code=\""+ouPersonCode+"\" data-user-mail>" + CFN_GetDicInfo(ouPersonName) + "</div>";
								   			} else {
								   				currentTarget	=	$$(oRecOUNode).find("ou").attr('name')+'함';
									   			currentTarget = CFN_GetDicInfo(currentTarget);
								   			}
						   				}
							   			
						   				
							   			
							   			html += "<ui class=\"listinfo\"><li>"+ this.item.SubKind  +" </li><li>"+ InitiatorName  +"</li><li>"+ this.item.InitiatorUnitName  +"</li><li>"+ getStringDateToString("yyyy.MM.dd HH:mm:ss",this.item.Created)  +"</li><li>"+ CFN_GetDicInfo(this.item.FormName)  +"</li><li>"+currentTarget+"</li><li class=\"poRela\"><span class=\"usa\" style=\"display: none;\">유사양식</span></li></ul></div>";
										
							   			return html;
							   	  }
			                  },	// 일시
			                  {key:'BusinessData4', label:'<spring:message code="Cache.ACC_useHistory"/>', width:'100', align:'left',showExcel:true, formatter:function () {//내역
									var comment = this.item.BusinessData4;
									if((comment.match(/<br>/gi) || []).length > 1) comment = comment.replace(/<br>/gi, '\r\n');
									return comment;
								}
							  },
			                  {key:'BusinessData3', label:'<spring:message code="Cache.ACC_billReqAmt"/>', width:'45', align:'right',showExcel:true, formatter:"money"}, //청구금액
			                  {key:'SubUserName', label:'<spring:message code="Cache.lbl_Sub_Approver"/>', display: false,  width:'100', align:'right',showExcel:true, formatter:function () {//대리기안자		
						   			
					   				var SubUserName = '';
					   				if(this.item.BusinessData5.indexOf('^^^')>-1)
					   					SubUserName = this.item.BusinessData5.split('^^^')[1];
						   			 
						   			return SubUserName;
			                  	}
		                  	  }, //대리기안자
		                  	{key:'IsComment', label:'<spring:message code="Cache.lbl_apv_comment"/>',  width:'10', align:'center',showExcel:true, formatter:function () {
			                		  if(this.item.IsComment == "Y"){
			                			  return "<a onclick='openCommentView_JF(\""+this.item.ProcessArchiveID+"\",\""+this.item.FormInstID+"\")' style='cursor: default;'><img src=\"/approval/resources/images/Approval/ico_comment.gif\" alt=\"\"></a>";
			                		  }
			                	  }
			                  }//의견
			                 ];


		 //완료함
	     var headerData2 =[
 						  {
      						display: false,
      						key: "showInfo", label: " " , width: "1", align: "center"
      					  },
			              {key:'chk', label:'chk', width:'20', align:'center', formatter:'checkbox'},
		                  {key:'SubKind', label:'<spring:message code="Cache.lbl_apv_gubun"/>', width:'45', align:'center',sort:false,showExcel:true,
		                	  formatter: function () {
		                		   return "<a onclick=\'showDetailInfo_JF(\""+this.index+"\");return false;'>"+this.item.SubKind+"</a>";
							   }
		                  },								   // 구분
		                  {key:'FormSubject', label:'<spring:message code="Cache.lbl_apv_subject"/>', width:'100', align:'left',showExcel:true,						       // 제목
						   	  formatter:function () {
						   			var html = "<div class=\"tableTxt\" style=\"width : 100%; text-overflow : ellipsis; white-space :  nowrap; overflow : hidden;\">"
						   			
						   			html += "<a class=\"taTit\" onclick='onClickPopButton_JF(\""+this.item.ProcessArchiveID+"\",\""+this.item.WorkItemArchiveID+"\",\"\",\""+this.item.PerformerID+"\",\""+this.item.ProcessDescriptionArchiveID+"\",\""+this.item.FormSubKind+"\",\""+this.item.FormInstID+"\",\""+this.item.BusinessData2+"\"); return false;'>"+this.item.FormSubject+"</a>";
						   									   			
						   			if(this.item.IsSecureDoc == "Y"){	html+= "<span class=\"security\"><spring:message code='Cache.lbl_apv_AuthoritySetting'/></span>";  }
						   			
						   			html += "</div>";
						   			
						   			return html;
								}
		                  },
		                  {key:'InitiatorUnitName',  label:'<spring:message code="Cache.lbl_DraftDept"/>', width:'55', align:'center',showExcel:true,
		                	  formatter:function(){return this.item.InitiatorUnitName;}
		                  },				           // 기안부서
		                  {key:'InitiatorName',  label:'<spring:message code="Cache.lbl_apv_writer"/>', width:'55', align:'center',showExcel:true,
		                	  formatter:function(){
	                		  		var InitiatorName = CFN_GetDicInfo(this.item.InitiatorName);
					   				var SubUserName = InitiatorName;
					   				if(this.item.BusinessData5.indexOf('^^^')>-1)
					   					SubUserName = CFN_GetDicInfo(this.item.BusinessData5.split('^^^')[1]);
					   				InitiatorName = (!SubUserName || SubUserName === "null" || InitiatorName === SubUserName)?InitiatorName:InitiatorName+'('+SubUserName+')';

									// 프리젠트 (FlowerName)
									InitiatorName = "<div class=\"btnFlowerName\" onclick=\"coviCtrl.setFlowerName(this)\" style=\"position:relative; cursor:pointer;\" data-user-code=\""+this.item.InitiatorID+"\" data-user-mail>" + InitiatorName + "</div>";
									
	                		  		return InitiatorName;
	                		  }
		                  },
		                  {key:'BusinessData4', label:'<spring:message code="Cache.ACC_useHistory"/>', width:'100', align:'left',showExcel:true, formatter:function () {
								var comment = this.item.BusinessData4.replace(/<br>/gi, '\r\n');
								return comment;
							}
						  }, //적요
		                  {key:'BusinessData3', label:'<spring:message code="Cache.ACC_billReqAmt"/>', width:'45', align:'right',showExcel:true, formatter:"money"}, //금액
		                  {key:'FormName',  label:'<spring:message code="Cache.lbl_FormNm"/>', width:'50', align:'center',showExcel:true,
		                	  formatter:function () {
		                		  return CFN_GetDicInfo(this.item.FormName);
	                	  	  }
		                  }, // 양식명
		                  {key:'DocNo',  label:'<spring:message code="Cache.lbl_DocNo"/>', width:'50', align:'center',showExcel:true},									   // 문서번호
		                  {key:'Finished', label:'<spring:message code="Cache.lbl_RepeateDate"/>' + Common.getSession("UR_TimeZoneDisplay"),  width:'60', align:'center',showExcel:true, sort:'desc',
		                	  formatter:function () {
		                			  return CFN_TransLocalTime(this.item.Finished);
		                	  }
		                   },				   // 일시
		                   {key:'SubUserName', label:'<spring:message code="Cache.lbl_Sub_Approver"/>', display: false, width:'100', align:'right',showExcel:true, formatter:function () {		
					   			
				   				var SubUserName = '';
				   				if(this.item.BusinessData5.indexOf('^^^')>-1)
				   					SubUserName = this.item.BusinessData5.split('^^^')[1];
					   			 
					   			return SubUserName;
		                  	}
	                  	  }, //대리기안자
		                  {key:'IsComment', label:'<spring:message code="Cache.lbl_apv_comment"/>',  width:'30', align:'center',sort:false,
		                	  formatter:function () {
		                		  if(this.item.IsComment == "Y"){
		                			  return "<a onclick='openCommentView_JF(\""+this.item.ProcessArchiveID+"\",\""+this.item.FormInstID+"\")' style='cursor: default;'><img src=\"/approval/resources/images/Approval/ico_comment.gif\" alt=\"\"></a>";
		                		  }
		                	  }
		                  },							   // 의견
		                  {key:'IsModify', label:'<spring:message code="Cache.lbl_Modify"/>', width:'30', align:'center',sort:false,
		                	  formatter:function () {
		                		  if(this.item.IsModify == "Y"){
		                			 // return "<a href=\"#none\"><img src=\"/approval/resources/images/approval/ico_research_join.gif\" alt=\"\"></a>";
		                			  return "<a onclick='openModifyPop_JF(\""+this.item.ProcessArchiveID+"\",\""+this.item.WorkItemArchiveID+"\",\""+this.item.PerformerID+"\",\""+this.item.ProcessDescriptionArchiveID+"\",\""+this.item.FormSubKind+"\",\"\",\""+this.item.FormInstID+"\",\"\",\"\",\""+this.item.UserCode+"\",\""+this.item.FormPrefix+"\")'><img src=\"/approval/resources/images/approval/ico_research_join.gif\" alt=\"\"></a>";
		                		  }
		                	  }
		                  }
		                  ];
	   	//반려함을 위한 그리드 헤더
	     var headerData3 =[
 						  {
      						display: false,
      						key: "showInfo", label: " " , width: "1", align: "center"
      					  },
			              {key:'chk', label:'chk', width:'20', align:'center', formatter:'checkbox'},
		                  {key:'SubKind', label:'<spring:message code="Cache.lbl_apv_gubun"/>', width:'45', align:'center',sort:false,showExcel:true,
		                	  formatter: function () {
		                		   return "<a onclick=\'showDetailInfo_JF(\""+this.index+"\");return false;'>"+this.item.SubKind+"</a>";
							   }
		                  },								   // 구분
		                  {key:'FormSubject', label:'<spring:message code="Cache.lbl_apv_subject"/>', width:'100', align:'left',showExcel:true,						       // 제목
						   	  formatter:function () {
						   			var html = "<div class=\"tableTxt\" style=\"width : 100%; text-overflow : ellipsis; white-space :  nowrap; overflow : hidden;\">"
						   			
						   			html += "<a class=\"taTit\" onclick='onClickPopButton_JF(\""+this.item.ProcessArchiveID+"\",\""+this.item.WorkItemArchiveID+"\",\"\",\""+this.item.PerformerID+"\",\""+this.item.ProcessDescriptionArchiveID+"\",\""+this.item.FormSubKind+"\",\""+this.item.FormInstID+"\",\""+this.item.BusinessData2+"\"); return false;'>"+this.item.FormSubject+"</a>";
						   									   			
						   			if(this.item.IsSecureDoc == "Y"){	html+= "<span class=\"security\"><spring:message code='Cache.lbl_apv_AuthoritySetting'/></span>";  }
						   			
						   			html += "</div>";
						   			
						   			return html;
								}
		                  },
		                  {key:'InitiatorUnitName',  label:'<spring:message code="Cache.lbl_DraftDept"/>', width:'55', align:'center',showExcel:true,
		                	  formatter:function(){return this.item.InitiatorUnitName;}
		                  },				           // 기안부서
		                  {key:'InitiatorName',  label:'<spring:message code="Cache.lbl_apv_writer"/>', width:'55', align:'center',showExcel:true,
		                	  formatter:function(){
	                		  		var InitiatorName = this.item.InitiatorName;
					   				var SubUserName = InitiatorName;
					   				if(this.item.BusinessData5.indexOf('^^^')>-1)
					   					SubUserName = this.item.BusinessData5.split('^^^')[1];
					   				InitiatorName = (!SubUserName || SubUserName === "null" || InitiatorName === SubUserName)?InitiatorName:InitiatorName+'('+SubUserName+')';

									// 프리젠트 (FlowerName)
									InitiatorName = "<div class=\"btnFlowerName\" onclick=\"coviCtrl.setFlowerName(this)\" style=\"position:relative; cursor:pointer;\" data-user-code=\""+this.item.InitiatorID+"\" data-user-mail>" + InitiatorName + "</div>";
									
	                		  		return InitiatorName;
	                		  }
		                  },
		                  {key:'BusinessData4', label:'<spring:message code="Cache.ACC_useHistory"/>', width:'100', align:'left',showExcel:true, formatter:function () {
								var comment = this.item.BusinessData4.replace(/<br>/gi, '\r\n');
								return comment;
							}
						  }, //적요
		                  {key:'BusinessData3', label:'<spring:message code="Cache.ACC_billReqAmt"/>', width:'45', align:'right',showExcel:true, formatter:"money"}, //금액
		                  {key:'Finished', label:'<spring:message code="Cache.lbl_RepeateDate"/>' + Common.getSession("UR_TimeZoneDisplay"),  width:'60', align:'center',showExcel:true, sort:'desc',
		                	  formatter:function () {
		                			  return CFN_TransLocalTime(this.item.Finished);
		                	  }
		                   },				   // 일시
		                   {key:'SubUserName', label:'<spring:message code="Cache.lbl_Sub_Approver"/>', display: false, width:'100', align:'right',showExcel:true, formatter:function () {		
					   			
				   				var SubUserName = '';
				   				if(this.item.BusinessData5.indexOf('^^^')>-1)
				   					SubUserName = this.item.BusinessData5.split('^^^')[1];
					   			 
					   			return SubUserName;
		                  	}
	                  	  }, //대리기안자
		                  {key:'IsComment', label:'<spring:message code="Cache.lbl_apv_comment"/>',  width:'30', align:'center',sort:false,
		                	  formatter:function () {
		                		  if(this.item.IsComment == "Y"){
		                			  return "<a onclick='openCommentView_JF(\""+this.item.ProcessArchiveID+"\",\""+this.item.FormInstID+"\")' style='cursor: default;'><img src=\"/approval/resources/images/Approval/ico_comment.gif\" alt=\"\"></a>";
		                		  }
		                	  }
		                  },							   // 의견
		                  {key:'IsModify', label:'<spring:message code="Cache.lbl_Modify"/>', width:'30', align:'center',sort:false,
		                	  formatter:function () {
		                		  if(this.item.IsModify == "Y"){
		                			 // return "<a href=\"#none\"><img src=\"/approval/resources/images/approval/ico_research_join.gif\" alt=\"\"></a>";
		                			  return "<a onclick='openModifyPop_JF(\""+this.item.ProcessArchiveID+"\",\""+this.item.WorkItemArchiveID+"\",\""+this.item.PerformerID+"\",\""+this.item.ProcessDescriptionArchiveID+"\",\""+this.item.FormSubKind+"\",\"\",\""+this.item.FormInstID+"\",\"\",\"\",\""+this.item.UserCode+"\",\""+this.item.FormPrefix+"\")'><img src=\"/approval/resources/images/approval/ico_research_join.gif\" alt=\"\"></a>";
		                		  }
		                	  }
		                  }
		                  ];

		if(clickedTab=="Approval" || clickedTab=="Process"){
			headerData = headerData1;
			ListGrid.setGridHeader(headerData1);
		}else if(clickedTab=="Complete" ){
			headerData = headerData2;
			ListGrid.setGridHeader(headerData2);
		}else if(clickedTab=="Reject"){
			headerData = headerData2;
			ListGrid.setGridHeader(headerData2);
		}
	}

 	/// 결재 상세정보 표시하기 위해 추가함 ////
    function showDetailInfo_JF(index) {
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
    }

	function setApprovalListData_JF(){		
		var url;
		if(clickedTab == "Approval"){
			url = "/approval/user/getJobFunctionApprovalListData.do";
		}else if(clickedTab == "Process"){
			url = "/approval/user/getJobFunctionProcessListData.do";
		}else if(clickedTab == "Complete"){
			url = "/approval/user/getJobFunctionCompleteListData.do";
		}else if(clickedTab == "Reject"){
			url = "/approval/user/getJobFunctionRejectListData.do";
		}
		if(searchValueValidationCheck()){		// 공통 함수
			setSelectParams(ListGrid);
			
			ListGrid.bindGrid({
				ajaxUrl: url,
				ajaxPars: selectParams,
				onLoad: function(){
 					accountCtrl.getInfoStr('.gridBodyTable > tbody > tr > td').css('background', 'white');
 					accountCtrl.getInfoStr('.AXGrid').css('overflow','visible'); 
					if(clickedTab == "Approval" || clickedTab == "Process"){
 						$('.listinfo').closest('td').children('div').css('overflow','visible');
 						$('.listinfo').css('overflow','visible');
 					}
 					if(clickedTab == "Complete" || clickedTab == "Reject"){
 						$('.btnFlowerName').parent().css('overflow','visible');
 					}
					setGridCount_JF();
					if(ListGrid.getCheckedList(1).length<=0){ //일괄 승인시 최상위 체크 박스가 유지되는 문제 해결
						ListGrid.checkedColSeq(1, false);
					}
				}
			});
		}
	}

	function onClickSearchButton_JF(){
		if(accountCtrl.getInfo("selectSearchType").val() !="" && accountCtrl.getInfo("searchInput").val() ==""){
			Common.Warning("<spring:message code='Cache.msg_EnterSearchword' />");							//검색어를 입력하세요
			accountCtrl.getInfo("searchInput").focus();
			return false;
		}
		ListGrid.page.pageNo = 1;				// 조회기능 사용시 페이지 초기화
		setGroupType(ListGrid, "/approval/user/getJobFunctionGroupList.do?clickTab="+clickedTab);			// 공통함수. 그룹별 보기 목록 다시 조회함.
		
		// 그룹별 보기 이후에 검색하는 경우 다시 선택할 수 있도록 조회결과 표시하지 않도록 수정
		if(accountCtrl.getInfo("seGroupID").attr("value") != "all") {
			ListGrid.bindGrid({page:{pageNo:1,pageSize:$("#selectPageSize").val(),pageCount:1},list:[]});
		}
		
		// 검색어 저장
		coviCtrl.insertSearchData(accountCtrl.getInfo("searchInput").val(), 'Approval');
	}
	
	function jobFunctionExcelDownLoad(){
		g_mode = "JOB"+clickedTab.toUpperCase();
		ExcelDownLoad(selectParams,getHeaderDataForExcel_Eac(),gridCount)
	}

	function setGridCount_JF(){
		gridCount = ListGrid.page.listCount;
	}


	function setSearchGroupWord(id){														// 공통함수에서 호출
		ListGrid.page.pageNo = 1;				// 조회기능 사용시 페이지 초기화
		
		accountCtrl.getInfo("hiddenGroupWord").val(id);
		schFrmSeGroupWord = id;
		
		// 클릭 시, hover 와 동일한 css 적용되도록 추가
		accountCtrl.getInfoStr("a[id^='fieldName_']").attr("style", "");
		accountCtrl.getInfoStr("a[id='fieldName_" + id + "']").css("background", "#4497dc");
		accountCtrl.getInfoStr("a[id='fieldName_" + id + "']").css("color", "#fff");
		
		if(accountCtrl.getViewPageDivID().indexOf("JobFunction") > -1 && typeof(setApprovalListData_JF) == "function") {
			setApprovalListData_JF();			
		} else {
			setApprovalListData();
		}
	}

	function onClickPopButton_JF(ProcessID,WorkItemID,TaskID,PerformerID,ProcessDescriptionID,Subkind,FormInstID,BusinessData2){
		var userCode = accountCtrl.getInfo("seFuncId").attr('value');
		
		switch (clickedTab){
			case "Approval" : mode="APPROVAL"; gloct="JOBFUNCTION"; subkind =Subkind; archived = "false";  break; // 미결함
			case "Process" : mode="PROCESS"; gloct="JOBFUNCTION"; subkind =Subkind; archived = "false";  break;    // 진행함
			case "Complete" : mode="COMPLETE"; gloct="JOBFUNCTION"; subkind =Subkind; archived = "true";  break;    // 완료함
			case "Reject" : mode="REJECT"; gloct="JOBFUNCTION"; subkind =Subkind; archived = "true";  break;    // 반려함
		}
		
		CFN_OpenWindow("/account/expenceApplication/ExpenceApplicationViewPopup.do?mode="+mode
				+"&processID="+ProcessID
				+"&workitemID="+WorkItemID
				+"&forminstanceID="+FormInstID
				+"&taskID="+TaskID
				+"&performerID="+PerformerID
				+"&processdescriptionID="+ProcessDescriptionID
				+"&userCode="+userCode
				+"&gloct="+gloct
				+"&ExpAppID="+BusinessData2
				+"&admintype=&archived="+archived
				+"&usisdocmanager=true&listpreview=N&subkind="+subkind+"", "", 1070, (window.screen.height - 100), "both");
		
		//ExpenceApplicationID == BusinessData2
		//CFN_OpenWindow("/account/expenceApplication/ExpenceApplicationViewPopup.do?ExpAppID="+BusinessData2+"&mode="+mode+"&gloct="+gloct+"&subkind="+subkind+"&archived="+archived,"", 1000, 850, "both");
	}

	function openModifyPop_JF(ProcessID,WorkItemID,PerformerID,ProcessDescriptionID,SubKind,FormTempInstBoxID,FormInstID,FormID,FormInstTableName,UserCode,FormPrefix){
		userCode = accountCtrl.getInfo("seFuncId").attr('value');
		switch (clickedTab){
			case "Complete" : mode="COMPLETE"; gloct="JOBFUNCTION"; subkind =Subkind; archived = "true";  break;    // 완료함
			case "Reject" : mode="REJECT"; gloct="JOBFUNCTION"; subkind =Subkind; archived = "true";  break;    // 반려함
		}
		CFN_OpenWindow("/approval/goHistoryListPage.do?ProcessID="+ProcessID+"&FormInstID="+FormInstID+"&FormPrefix="+FormPrefix+"&workitemID="+WorkItemID+"&performerID="+PerformerID+"&processdescriptionID="+ProcessDescriptionID+"&userCode="+userID+"&gloct="+gloct+"&formID="+FormID+"&formtempID="+FormTempInstBoxID+"&forminstancetablename="+FormInstTableName+"&admintype=&archived="+archived+"&usisdocmanager=true&listpreview=N&subkind="+subkind+"&mode="+mode+"&type=List", "", 830, (window.screen.height - 100), "both");
	}
	
	function openCommentView_JF(ProcessID,FormInstID) {
		var archived = "false";
		switch(clickedTab) {
			case "Complete": case "Reject": archived = "true"; break;
		}
		CFN_OpenWindow("/approval/goCommentViewPage.do?ProcessID="+ProcessID+"&FormInstID="+FormInstID+"&archived="+archived+"&bstored="+bstored, "", 540, 500, "resize");
	}
	
	
	if (!window.JobFunctionList) {
		window.JobFunctionList = {};
	}

	(function(window) {
		var JobFunctionList = {
			
			pageView : function() {
				approvalListType = "jobFunction";		
				groupUrl = "/approval/user/getJobFunctionGroupList.do?clickTab=Approval";
				
				clickTab(accountCtrl.getInfo("aApprovalPage"));	
			}
		}

		window.JobFunctionList = JobFunctionList;
	})(window);

</script>