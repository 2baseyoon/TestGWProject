<%@page import="egovframework.baseframework.util.PropertiesUtil"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<%
	String searchWord = request.getParameter("searchWord");
	String searchType = request.getParameter("searchType");
	String searchWordStatus = request.getParameter("searchWordStatus");
	String searchTypeStatus = request.getParameter("searchTypeStatus");
	String sortColumn = request.getParameter("sortColumn");
	String sortDirection = request.getParameter("sortDirection");
%>
<% 
	String resourceVersion = egovframework.coviframework.util.ComUtils.getResourceVer();
%>
<script type="text/javascript" src="/groupware/resources/script/user/tf.js<%=resourceVersion%>"></script>
<div class="cRConTop titType">
	<h2 class="title"><spring:message code='Cache.lbl_ProgressReport'/></h2>						
	<div class="searchBox02" style="display:none">
		<span>
			<input id="subjectSearchText" type="text">
			<button type="button" class="btnSearchType01" onclick="javascript:subjectSearch($('#subjectSearchText').val())"><spring:message code='Cache.btn_search'/></button>	<!-- 검색 -->
		</span>
		<a href="#" class="btnDetails"><spring:message code='Cache.lbl_detail'/></a>	<!-- 상세 -->
	</div>
</div>
<div class="cRContBottom mScrollVH ">
	<div class="inPerView type02">
		<div>
			<div class="selectCalView">
				<span><spring:message code='Cache.lbl_Contents'/></span>	<!-- 내용 -->
				<select id="searchType" class="selectType02">
					<option value="Subject"><spring:message code='Cache.lbl_Title'/></option>	<!-- 제목 -->
					<option value="BodyText"><spring:message code='Cache.lbl_Contents'/></option><!-- 내용 -->
					<option value="CreatorName"><spring:message code='Cache.lbl_writer'/></option><!-- 작성자 -->
					<option value="Total"><spring:message code='Cache.lbl_Title'/> + <spring:message code='Cache.lbl_Contents'/></option>
				</select>
				<div class="dateSel type02">
					<input id="searchText" type="text">
				</div>											
			</div>
			<div>
				<a href="#" id="btnSearch" class="btnTypeDefault btnSearchBlue nonHover"><spring:message code='Cache.btn_search'/></a> <!-- 검색 -->
			</div>
			<div class="chkGrade">									
				<div class="chkStyle01">
					<input type="checkbox" id="chkRead"><label for="chkRead"><span></span><spring:message code='Cache.lbl_Mail_Unread'/></label><!-- 읽지않음 -->
				</div>
			</div>
		</div>
		<div>
			<div class="selectCalView">
			<span><spring:message code='Cache.lbl_Period'/></span>	<!-- 기간 -->
				<select id="selectSearch" class="selectType02">
				</select>
				<div id="divCalendar" class="dateSel type02">
					<input class="adDate" type="text" id="startDate" date_separator="." readonly=""> - <input id="endDate" date_separator="." kind="twindate" date_startTargetID="startDate" class="adDate" type="text" readonly="">
				</div>											
			</div>
		</div>
	</div>
	<div id="ITMSubCont">	<!-- class: boardCommCnt, docAllCont -->
		<!-- #tabList -->
		<ul id="tabList" class="tabType2 clearFloat" style="display:none;">
		</ul>
		<div id="switchTopCnt" class="ITMTopCont teamroomprogressTop checkType">
			<div class="cRConTop titType">
				<a href="#" id="btnRefresh" class="btnTypeDefault left" onclick="javascript:deleteActivity();"><spring:message code='Cache.btn_Refresh'/></a>	<!-- 새로고침 -->
				<select id="selYear" class="selectType02 listCount" style="width:70px;">
				</select>
				<spring:message code='Cache.lbl_year'/>
				<select id="selMonth" class="selectType02 listCount" style="width:60px;">
				</select>
				월
				<select id="selGubun" class="selectType02 listCount" style="width:80px;" >
					<option value="M"><spring:message code='Cache.lbl_weeklyShow'/></option>
					<option value="D" selected><spring:message code='Cache.lbl_DailyShow'/></option>
				</select>
			</div>
			<div class="trpchk">
				<div class="chkStyle06">
					<input type="checkbox" id="chk_name" onclick="FieldDisplay(1, (this.checked ? true : false));" checked="" value="1"><label for="chk_name">작업이름</label>
				</div>		
				<div class="chkStyle06">
					<input type="checkbox" id="chk_during" onclick="FieldDisplay(2, (this.checked ? true : false));" checked="" value="2"><label for="chk_during">기간</label>
				</div>
				<div class="chkStyle06">
					<input type="checkbox" id="chk_start" onclick="FieldDisplay(3, (this.checked ? true : false));" checked="" value="3"><label for="chk_start">시작날짜</label>
				</div>
				<div class="chkStyle06">
					<input type="checkbox" id="chk_end" onclick="FieldDisplay(4, (this.checked ? true : false));" checked="" value="4"><label for="chk_end">종료날짜</label>
				</div>
				<div class="ITMinfoPopBtnBox">
					<button href="#" class="btnquestionmark" type="button"></button>
					<ul class="topOptionListCont  ITMinfoPopList active" style="display:none;">
						<li><a href="#" class="btnXClose btnShareListBoxClose btnTopOptionContClose"></a></li>
						<li>
							<div class="chkStyle03">
								<input type="checkbox"><label for="allSV0166"><span class="ITMwaitColor"></span>대기</label>
							</div>
						</li>		
						<li>
							<div class="chkStyle03">
								<input type="checkbox"><label for="allSV0167"><span class="ITMprogressColor"></span>진행</label>
							</div>
						</li>
						<li>
							<div class="chkStyle03">
								<input type="checkbox"><label for="allSV0168"><span class="ITMfinishColor"></span>완료</label>
							</div>
						</li>	
					</ul>
				</div>
			</div>			
		</div>
		<!-- 목록보기-->
		<div id="ProgressTable" class="ITMtrpfield_table_wrap"></div>
	</div>												
</div>
<!-- 툴팁 -->
<div id="divLangSelect" style="background-color:white;"></div>

<input type="hidden" id="hiddenMenuID" value=""/>
<input type="hidden" id="hiddenCU_ID" value=""/>
<input type="hidden" id="hiddenAT_ID" value=""/>
<input type="hidden" id="hiddenComment" value="" />
 <!-- ==== 히든필드 시작 ===== -->
<input type="hidden"  id="hidYear"   value="" />
<input type="hidden"  id="hidMonth"  value="" />
<input type="hidden"  id="hidGubun"  Value="D" />
 <!-- ==== 히든필드 종료 ===== -->
<script>
	//# sourceURL=TFProgress.jsp
	var communityId = typeof(cID) == 'undefined' ? 0 : cID;	// 커뮤니티ID
	var activeKey = typeof(mActiveKey) == 'undefined' ? 1 : mActiveKey;	// 커뮤니티 메뉴 Key
	
	//개별호출-일괄호출
	var sessionObj = Common.getSession(); //전체호출
	
	var lang = sessionObj["lang"];
	var userID = sessionObj["USERID"];

	//ready
	init();
	
	function init(){
		initControl();		
		
		//getActivityProgress();
	}	
	
	var MaxDate, MinDate;
	var MinYear;
	var MaxYear;
	var MinMonth;
	var MaxMonth;
	function initControl(){
        $("#selYear").change(function () {
            $("#hidYear").val($(this).val());
            getActivityProgress();
        });

        $("#selMonth").change(function () {
            $("#hidMonth").val($(this).val());
            getActivityProgress();
        });
        $("#selGubun").change(function () {
            $("#hidGubun").val($(this).val());
            getActivityProgress();
        });       
      //프로젝트 년도 및 월 채워넣기 - 작업할 것
		//대분류 select data	selCategory
		$.getJSON('/groupware/tf/getActivityMinMaxDate.do', {CU_ID : communityId}, function(d) {
			d.list.forEach(function(d) {
				MaxDate = d.MaxDate;
				MinDate = d.MinDate;
			});
			
			MinYear = MinDate.substring(0,4);
			MaxYear = MaxDate.substring(0,4);
			MinMonth = MinDate.substring(5,7);
			MaxMonth = MaxDate.substring(5,7);
			
			for(var i=MinYear;i<=MaxYear;i++){
				$('#selYear').append($('<option>', {
					value : i ,
			     	text : i
				}));
			}
			// 초기셋팅
			// 년도 정보가 최소 년도가 아닌 경우 1월부터
			// 년도 정보가 최대 년도가 아닌 경우 12월까지
			if(MinYear < MaxYear){
				for(var i=1;i<=12;i++){
					$('#selMonth').append($('<option>', {
						value : CFN_PadLeft(String(i),2,'0') ,
				     	text :  CFN_PadLeft(String(i),2,'0')
					}));
				}
			}else{
				for(var i=parseInt(MinMonth);i<=12;i++){
					$('#selMonth').append($('<option>', {
						value : CFN_PadLeft(String(i),2,'0') ,
				     	text :  CFN_PadLeft(String(i),2,'0')
					}));
				}
			}
			getActivityProgress();
		}).error(function(response, status, error){
			//TODO 추가 오류 처리
			CFN_ErrorAjax("/groupware/tf/getTaskList.do", response, status, error);
		});        
	}
	
    //구분 숨기기/보이기
    function FieldDisplay(gubun, isCheck) {
        if (isCheck) {
            $("#ProgressTable").find(".HeaderCell").eq(gubun).show();
            $("#ProgressTable").find(".ITMtrp_Titlist").each(function () {
                $(this).find("td").eq(gubun).show();
            });
            $("#ProgressTable").find(".ITMtrp_Sublist").each(function () {
                $(this).find("td").eq(gubun).show();
            });            
            $("col").eq(gubun).show();

        } else {
            $("#ProgressTable").find(".HeaderCell").eq(gubun).hide();
            $("#ProgressTable").find(".ITMtrp_Titlist").each(function () {
                $(this).find("td").eq(gubun).hide();
            });
            $("#ProgressTable").find(".ITMtrp_Sublist").each(function () {
                $(this).find("td").eq(gubun).hide();
            });            
            $("col").eq(gubun).hide();
        }
    }
    //Task 마우스오버
    function helpBoxTask(e, taskid, parent, Name, Date, Progress, Member, Gubun) {
        var divTop = e.clientY + 20; //상단 좌표
        var divLeft = e.clientX - 175; //좌측 좌표
        var memberlist = "";//CodeChange(taskid);
        $('#divLangSelect').html(
            "<div style='font-size:17px; font-weight:bold; color:#009de0;'>" + Name + "(진도율 : <span style=color:red;>" + Progress + "%</span>)" + "</div>" +
            "<div style='font-size:15px;'>구분 : " + Gubun + "</div>" +
            "<div style='font-size:15px;'>기간 : " + Date + "</div>" +
            "<div style='font-size:15px;'>진도율 : " + Progress + "%</div>" 
            );
        $('#divLangSelect').css({
            "top": divTop
            , "left": divLeft
            , "position": "absolute"
        }).show();
    }
    //Activity 마우스오버
    function helpBoxAct(e, activityid,Name, Date, Progress, Gubun) {
        var divTop = e.clientY + 20; //상단 좌표
        var divLeft = e.clientX - 175; //좌측 좌표
        var memberlist = "";//CodeChange(activityid);
        $('#divLangSelect').html(
        "<div style='font-size:17px; font-weight:bold; color:#009de0;'>" + Name + "(진도율 : <span style=color:red;>" + Progress + "%</span>)" + "</div>" +
        "<div style='font-size:15px;'>구분 : " + Gubun + "</div>" +
            "<div style='font-size:15px;'>기간 : " + Date + "</div>" 
            );
        $('#divLangSelect').css({
            "top": divTop
            , "left": divLeft
            , "position": "absolute"
        }).show();
    }

    //
    function helpBoxHide() {
        $('#divLangSelect').hide();
    }

    //일/주단위 클릭
    function SearchGubun(gubun) {
        $("#hidGubun").value = $(gubun).val();
    }
    //담당자 코드변환(UR> ExDisplayName)
    function CodeChange(pActivityID) {
        var List = "";
        if (pActivityID != "") {
			$.getJSON("/groupware/tf/getPerformerData.do", {AT_ID : pActivityID}, function(d) {
				d.performerList.forEach(function(d) {
					List += d.DeptName + " " + d.Name + ",";
				});
			}).error(function(response, status, error){
				//TODO 추가 오류 처리
				CFN_ErrorAjax("/groupware/tf/getPerformerData.do", response, status, error);
			});
        }
        return List;
    }
	// 제목 클릭 
	function ViewAT(ActivityId) {
		Common.open("","ActivitySet","<spring:message code='Cache.btn_view' />","/groupware/tf/goActivityView.do?mode=VIEW&CLSYS=TF&CLMD=user&CLBIZ=TF&CSMU=T&C="+communityId+"&ActivityId="+ActivityId ,"950px", "650px","iframe", true,null,null,true);
	}    
</script>			