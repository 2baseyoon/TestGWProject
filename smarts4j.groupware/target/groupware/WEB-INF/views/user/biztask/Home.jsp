<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>

<!-- 통합업무관리 포탈 시작-->
<!-- 리스트 시작 -->
<div class="cRContBottom mScrollVH ITMPortalCont">
<div class="ITMPortalWrap">
	<p class="ITMTopTitle"><spring:message code='Cache.lbl_myworkreport' /></p>
	<div class="ITMListWrap">
		<div class="ITMListBox_p">
			<div class="ITMListBox">
				<div class="ITMList_Top">
					<h3 class="ITMList_Toptitle"><spring:message code='Cache.lbl_Project' /></h3><a href="#" onClick="javascript:CoviMenu_GetContent('/groupware/layout/biztask_MyTask.do?CLSYS=biztask&CLMD=user&CLBIZ=BizTask');" class="ITMList_morebtn" ><spring:message code='Cache.lbl_MoreView' />+</a>
				</div>
				<div class="ITMList_Cont">
					<div class="ITMList" id="divMyProjectList">
					</div>
					<!-- 조회목록없음 //최근구입자신 및 자산변경 내용없을 때 사용// 시작-->
					<div class="ITMList_none" style="display:none" id="divMyProjectListNone"><spring:message code='Cache.msg_NoDataList' /></div>
					<!-- 조회목록없음 //최근구입자신 및 자산변경 내용없을 때 사용 내용없을 때 사용//  끝-->
				</div>
			</div>
		</div>
		<div class="ITMListBox_p">
			<div class="ITMListBox">
				<div class="ITMList_Top">
					<h3 class="ITMList_Toptitle"><spring:message code='Cache.lbl_TaskManage' /></h3><a href="#" onClick="javascript:CoviMenu_GetContent('/groupware/layout/biztask_MyTask.do?CLSYS=biztask&CLMD=user&CLBIZ=BizTask');" class="ITMList_morebtn"><spring:message code='Cache.lbl_MoreView' />+</a>
				</div>
				<div class="ITMList_Cont">
					<div class="ITMList" id="divMyWorkList">
					</div>
					<!-- 조회목록없음 //최근구입자신 및 자산변경 내용없을 때 사용// 시작-->
					<div class="ITMList_none" style="display:none" id="divMyWorkListNone"><spring:message code='Cache.msg_NoDataList' /></div>
					<!-- 조회목록없음 //최근구입자신 및 자산변경 내용없을 때 사용 내용없을 때 사용//  끝-->
				</div>
			</div>
		</div>
	</div>
	<!-- 리스트 끝-->
	<p class="ITMTopTitle" id="pTitle"><spring:message code='Cache.lbl_projectstatus' /><select id="selTeam" class="selectType02" onchange="selTeamChange(this);"></select> </p>
	<div class="ITMContentWrap" id="divSummary">
		<div class="ITMContentBox_p">
			<div class="ITMContentBox">
				<div class="ITMContentIco"></div>
				<div class="ITMContentInfo">
					<div class="ITMContentInfoTit"><span><spring:message code='Cache.lbl_itsummary' /></span><span id="spanTotal">전체 업무 0건</span></div>
					<ul class="ITMContentInfoList">
						<li>
							<span><spring:message code='Cache.lbl_projectwork' /></span>
							<span id="spanTotalProject"><strong>0</strong>건</span>
						</li>
						<li>
							<span><spring:message code='Cache.lbl_generalwork' /></span>
							<span id="spanTotalTask"><strong>0</strong>건</span>
						</li>
						<li>
							<span><spring:message code='Cache.lbl_delaywork' /></span>
							<span id="spanTotalDelay"><strong>0</strong>건</span>
						</li>
						<li>
							<span><spring:message code='Cache.lbl_progresswork' /></span>
							<span id="spanTotalProcess"><strong>0</strong>건</span>
						</li>
					</ul>
				</div>
			</div>
		</div>
		<div class="ITMContentBox_p">
			<div class="ITMContentBox">
				<div class="ITMList_Top">
					<h3 class="ITMList_Toptitle">
						<select class="selectType02" id="selProjectMode" onchange="selProjectModeChange(this);">
							<option value="D"><spring:message code='Cache.lbl_delayproject' /></option>
							<option value="P"><spring:message code='Cache.lbl_progressproject' /></option>
						</select>
					</h3>
					<div class="rMPListpaging">
						<span class="pagingType01" id="spanpaging" style="display:none;">
							<a href="#" class="pre" onclick="pageclick('pre');"></a>
							<a href="#" class="next" onclick="pageclick('next');"></a>
						</span>
						<span class="pagecount"><span id="spancurrent">0</span>/<span id="spantotalpagecnt">0</span></span>
					</div>
				</div>
				<div class="ITMContentTableWrap">
					<table cellpadding="0" cellspacing="0" class="ITMContentTable" id="tblProject">
					<colgroup>
						<col width="">
						<col width="">
						<col width="130">
						<col width="110">
					</colgroup>
					<thead>
						<tr>
							<th><spring:message code='Cache.lbl_Project' /></th>
							<th><spring:message code='Cache.lbl_scope'/></th>
							<th><spring:message code='Cache.lbl_HeadDept'/></th>
							<th><spring:message code='Cache.lbl_ProgressRate'/></th>
						</tr>
					</thead>
					<tbody>
					</tbody>
					</table>
				</div>
			</div>
		</div>
	</div>
</div>
</div>
<!-- 프로젝트관리 포탈 끝 -->

<script>
	var userCode = Common.getSession("UR_Code");
	var deptCode = "";	
	var lang = Common.getSession("lang");	
	var currentDate = "";
	var objMyTeamList; //관리부서 정보
	initHome();
	
	function initHome() {
		var rDate = new Date();
		currentDate = rDate.format("yyyy-MM-dd");				
		init();
	}
	
	function init(){
		setMyWork(); //내업무
		setMyTeams(); //내가 관리하는 팀 리스트 가져오기 없을 경우..
	}
	function setMyWork(){
		$.getJSON("/groupware/biztask/getMyTaskList.do",{userCode : userCode}, function(d) {
			var projectTaskDaily = d.ProjectTaskList;
			var taskDaily = d.TaskList;
			var htmlDaily = "";
			if((projectTaskDaily.length + taskDaily.length) == 0){
				$("#divMyProjectList").hide();
				$("#divMyWorkList").hide();
				$("#divMyProjectListNone").show();
				$("#divMyWorkListNone").show();
			}else{
				if(projectTaskDaily.length == 0){
					$("#divMyProjectList").hide();
					$("#divMyProjectListNone").show();
				}else{
					$("#divMyProjectListNone").hide();					
					//프로젝트 업무보고 출력
					var liHTML="";
					projectTaskDaily.forEach(function(item, idx) {
						if(idx < 5){
							liHTML +='<li><a href="#" onclick="openPop(\''+item.CU_ID +'\',\''+item.AT_ID +'\',\'Y\')">';
							liHTML +='<span class="ITMList_division">'+item.CommunityName+'</span>';
							if(item.EndDate < currentDate ){
								liHTML +='<span class="ITMList_title delay">'+(item.DelayDay < 7 ? '<span class="cycleNew blue new">N</span>':'')+"[<spring:message code='Cache.lbl_Delay' />]"+item.ATName+'</span>';
							}else{
								liHTML +='<span class="ITMList_title">'+item.ATName+'</span>';
							}
							liHTML +='<span class="ITMList_date">'+'~'+item.EndDate+'</span>';
							liHTML +='<span class="ITMList_percentage">'+item.Progress+'%</span>';
							liHTML +='</a></li>';
						}
					});
					$("#divMyProjectList").html("<ul>"+liHTML+"</ul>");
					$("#divMyProjectList").show();
				}
				if(taskDaily.length == 0){
					$("#divMyWorkList").hide();
					$("#divMyWorkListNone").show();					
				}else{
					var liHTML="";
					//Task 업무보고 출력
					taskDaily.forEach(function(item, idx) {
						if(idx < 5){
							var isOwner = (item.RegisterCode==userCode || item.OwnerCode == userCode)? "Y":"N";
							liHTML +='<li><a href="#" onclick="goTaskSetPopup(\''+item.TaskID +'\',\''+item.FolderID +'\',\''+ isOwner +'\')" >'
							liHTML +='<span class="ITMList_division">'+item.DisplayName+'</span>';
							if(item.EndDate < currentDate ){
								liHTML +='<span class="ITMList_title delay">'+(item.DelayDay < 7 ? '<span class="cycleNew blue new">N</span>':'')+"[<spring:message code='Cache.lbl_Delay' />]"+item.Subject+'</span>';
							}else{
								liHTML +='<span class="ITMList_title">'+item.Subject+'</span>';
							}					
							liHTML +='<span class="ITMList_date">'+'~'+item.EndDate+'</span>';
							liHTML +='<span class="ITMList_percentage">'+item.Progress+'%</span>';
							liHTML +='</a></li>';
						}
					});
					$("#divMyWorkList").html("<ul>"+liHTML+"</ul>");
					$("#divMyWorkList").show();				
				}				
			}
		});			
	}
	// Activity 
	function openPop(pcommunityId, ActivityId, isOwner) {
		Common.open("","ActivitySet","<spring:message code='Cache.btn_Modify' />","/groupware/tf/goActivitySetPopup.do?mode=MODIFY&CLSYS=biztask&CLMD=user&CLBIZ=BizTask&CSMU=T&C="+pcommunityId+"&ActivityId="+ActivityId+"&isOwner="+isOwner ,"950px", "650px","iframe", true,null,null,true);
	}
	function search(){
		setListData();
	}
	//Task
	//업무 수정/조회 팝업 
	function goTaskSetPopup(taskID,folderID,isOwner,isSearch){
		var height = isOwner=="Y"? "650px": "570px";
		Common.open("","taskSet",Common.getDic("lbl_task_taskManage"),"/groupware/task/goTaskSetPopup.do?mode=Modify&isOwner="+isOwner+"&taskID="+taskID+"&folderID="+folderID+"&isSearch="+isSearch,"950px", height ,"iframe", true,null,null,true);
	}
	
	function getFolderItemList(){
	}	
	function setMyTeams(){
		//내팀가져오기
		$.getJSON("/groupware/biztask/getMyTeams.do",{userCode : userCode}, function(d) {
			objMyTeamList = d.MyTeamList;
			if(objMyTeamList.length == 0){
				$('#pTitle').html('프로젝트 현황');
				setSummaryData();
				//$("#divSummary").html("<spring:message code='Cache.msg_NoDataList' />");
			}else{
				if(d.MyTeamList.length == 1){
					d.MyTeamList.forEach(function(d) {
						$('#pTitle').html(CFN_GetDicInfo(d.MultiDisplayName,lang) + "<spring:message code='Cache.lbl_projectstatus' />");
						if(deptCode == ""){
							deptCode = d.GroupCode;
						}
					});
				}else{
					d.MyTeamList.forEach(function(d) {
						$('#selTeam').append($('<option>', {
							value : d.GroupCode ,
					     	text : CFN_GetDicInfo(d.MultiDisplayName,lang)
						}));
						if(deptCode == ""){
							deptCode = d.GroupCode;
						}
					});
				}
				setSummaryData();
			}
		}).error(function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("/groupware/biztask/getMyTeams.do", response, status, error);
		});		
	}
	function selTeamChange(obj){
		deptCode = $(obj).val();
		setSummaryData();
	}
	function setSummaryData(){
		$.getJSON("/groupware/biztask/getMyTeamProjectSummary.do",{deptCode : deptCode}, function(d) {
			$("#spanTotal").text("<spring:message code='Cache.lbl_allwork' />"+" : "+(d.projectlist.length+d.tasklist.length));
			$("#spanTotalProject").html("<strong>"+d.projectlist.length+"</strong>");
			$("#spanTotalTask").html("<strong>"+d.tasklist.length+"</strong>");
			var delaycnt=0;
			var processcnt=0;
			d.projectlist.forEach(function(d) {
				if( parseInt(d.DELAYCNT) > 0 ){ delaycnt++;}else{processcnt++;}
			});
			d.tasklist.forEach(function(d) {
				if( parseInt(d.DELAYCNT) > 0 ) { delaycnt++;}else{processcnt++;}
			});			
			
			$("#spanTotalDelay").html("<strong>"+delaycnt+"</strong>");
			$("#spanTotalProcess").html("<strong>"+processcnt+"</strong>");
			setListData();

		}).error(function(response, status, error){
		     //TODO 추가 오류 처리
		     CFN_ErrorAjax("/groupware/biztask/getMyTeams.do", response, status, error);
		});		
	}
	var projectViewMode="D";
	function selProjectModeChange(obj){
		projectViewMode = $(obj).val();
		curruntPage=1;
		setListData();
	}
	//진행중인 프로젝트, 대기중인 프로젝트
	var curruntPage=1;
	var pageSize = 5;
	function setListData(){
		$.ajax({
			url:"/groupware/biztask/getHomeProjectListData.do",
			data:{
				"deptCode" : deptCode,
				"mode" : projectViewMode,
				"pageNo" : curruntPage,
				"pageSize" : pageSize
			},			
			type:"post",
			success:function (data) {
				//페이징 정보
				var pageobject = data.page;
				var projectlist = data.list;
				$("#spantotalpagecnt").text(pageobject.pageCount);
				$("#spancurrent").text(pageobject.pageNo);
				
				if(pageobject.listCount == 0 ){
					$("#tblProject > tbody").empty();
					var outterTr = $("<tr></tr>").html("<td colspan='4' align='center'></td>").show();
					outterTr.find("td").eq(0).text("<spring:message code='Cache.msg_NoDataList' />");
					$("#tblProject > tbody").append(outterTr);	
					$("#spanpaging").hide();
				}else{
					$("#tblProject > tbody").empty();
					projectlist.forEach(function(item, idx){
						var outterTr = $("<tr></tr>").html("<td align='center'></td><td align='center'></td><td align='center'></td><td align='center'></td>").show();
						outterTr.find("td").eq(0).html('<a href="#" onclick="goCommunitySite('+item.CU_ID+')">'+item.CommunityName+'</a>');
						outterTr.find("td").eq(1).text(item.TF_StartDate + '~' + item.TF_EndDate + '(총'+item.TF_TERM+'개월)');
						outterTr.find("td").eq(2).text(item.TF_MajorDept);
						outterTr.find("td").eq(3).html('<span class="ITMContentTable_percentage">'+(Common.getBaseConfig('IsUseWeight') == 'Y'?item.TF_WProgress:item.TF_AVGProgress)+'%</span>'); // (가중치)
						$("#tblProject > tbody").append(outterTr);					
					});
					$("#spanpaging").show();
				}
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/groupware/biztask/getHomeProjectListData.do", response, status, error);
			}
		});
	}
	function goCommunitySite(community){
		 var specs = "left=10,top=10,width=1050,height=900";
		 specs += ",toolbar=no,menubar=no,status=no,scrollbars=no,resizable=no";
		 //window.open("/groupware/layout/userTF/TFMain.do?C="+community, "TF"+community, specs);
		 window.open("/groupware/layout/userCommunity/communityMain.do?C="+community, "community", specs);	 		 
	}
	function setProjectBoxListData(data, id) {
		var html = "";
		
		$("#" + id).html("");
		
		if(data.length > 0){
			$("#" + id + "Cnt").text(data.length);
			
			$(data).each(function(i,v){
				html += "<a onclick='goProjectDetail(" + v.PrjCode + ")'><div class='projectPListSlideCont'>";
				html += "<ul value='" + (i+1) + "' >"
				html += "<li><span class='ProjectMList_title'>" + v.PrjName + "</span></li>";
				html += "<li><span class='ProjectMList_date'>" + v.ConStartDate + " ~ " + v.ConEndDate + "</span></li>";
				html += "<li><span class='ProjectMList_p'> " + v.PMName + "(PM)</span></li>";
				html += "<li><div class='participationRateBar'><div style='width: " + v.PrjPercent + "px'></div></div><span>" + v.PrjPercent + "%</span></li>";
				html += "</ul>"
				html += "</div></a>";
			});	
		} else {
			html += "<li><span class='ProjectM_none'>조회할 목록이 없습니다.</span></li>";
			$("#" + id + "Bottom").hide();
		}
		
		$("#" + id).html(html);
	}
	
	function initEvent(){
		//진행중인 프로젝트
		$('.projectPListSlide').slick({arrows: false, autoplay: true});
		
		$('.projectPlistSlidePrev').on('click', function(){
			$('.projectPListSlide').slick('slickPrev');
		});
		$('.projectPlistSlideNext').on('click', function(){
			$('.projectPListSlide').slick('slickNext');
		});
		
		$('.projectPListSlide').on('afterChange', function (event, slick, currentSlide) {
			$("#pCurrentCnt").text(currentSlide+1);
		}); 
		
		//대기중인 프로젝트		
		$('.projectRListSlide').slick({arrows: false, autoplay: true});
		
		$('.projectRlistSlidePrev').on('click', function(){
			$('.projectRListSlide').slick('slickPrev');
		});
		$('.projectRlistSlideNext').on('click', function(){
			$('.projectRListSlide').slick('slickNext');
		});
		
		$('.projectRListSlide').on('afterChange', function (event, slick, currentSlide) {
			$("#rCurrentCnt").text(currentSlide+1);
		}); 
	}
	
	//보고현황
	function setReportData() {
		var html = "";
		
		$.ajax({
			url:"/groupware/project/getHomeReportData.do",
			type:"POST",
			async:false,
			success:function (data) {
				var html = "";
				
				$("#reportData").html("");
				
				if(data.list.list.length > 0){
					$(data.list.list).each(function(i,v){
						html += "<a onclick='goTaskReportWeeklyView(" + v.RepIDX + ")'>";
						html += "<div class='ProjectMO_MLeft'>";
						html += "<p class='ProjectMO_YM'>" + v.RegistDate.substring(0,7) + "</p><p class='ProjectMO_D'>" + v.RegistDate.substring(8,10) + "</p>";
						html += "</div>";
						html += "<div class='ProjectMO_MRight'><ul>";
						html += "<li><span class='ProjectMO_RSTitle'>프로젝트명</span><span class='ProjectMO_RSCont'>" + v.PrjName + "</span></li>";
						html += "<li><span class='ProjectMO_RSTitle'>기간</span><span class='ProjectMO_RSCont'>" + v.StartDate + " ~ " + v.EndDate + "</span></li>";
						html += "<li><span class='ProjectMO_RSTitle'>진행율</span><span class='ProjectMO_RSCont'>" + v.PrjPercent + "</span></li>";
						html += "<li><span class='ProjectMO_RSTitle'>등록자</span><span class='ProjectMO_RSCont'>" + v.MemName + "</span></li>";
						html += "</ul></div></a>"

					});	
				} else {
					$("#reportNonData").show();
				}
				
				$("#reportData").html(html);
			},
			error:function(response, status, error){
				CFN_ErrorAjax("/groupware/project/getHomeReportData.do", response, status, error); 
			}
		}); 
	}
	

	function goProjectDetail(prjCode){
		var url = '';
		url = String.format("/groupware/layout/project_ProjectDetailStatus.do?CLSYS=project&CLMD=user&CLBIZ=Project&PrjCode={0}&mode={1}", prjCode, 'S');
		CoviMenu_GetContent(url);
	}
	
	function goTaskReportWeeklyView(idx) {
		var url = '';
		url = String.format("/groupware/layout/project_TaskReportWeeklyView.do?CLSYS=project&CLMD=user&CLBIZ=Project&RepIDX={0}", idx)  ;
		CoviMenu_GetContent(url);
	}
	function pageclick(pmode){
		switch(pmode){
			case "pre": 
				if(currentPage > 1){ 
					currentPage--;setListData();
				}
				break;
			case "next": 
				if(currentPage < parseInt($("#spantotalpagecnt").text())){
					currentPage++;
					setListData();
				}
				break;
		}
	}
	
</script>
