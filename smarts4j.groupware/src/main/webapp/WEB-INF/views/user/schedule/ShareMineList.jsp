<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<jsp:include page="/WEB-INF/views/cmmn/UserInclude.jsp"></jsp:include>

<body>	
	<div class="layer_divpop ui-draggable schPopLayer" id="testpopup_p" style="width:420px;" source="iframe" modallayer="false" layertype="iframe" pproperty="">
		<div class="divpop_contents">
			<div class="popContent schListVIewPopup">
				<div class="">
					<div class="top">
						<div class="inPerView type04  active">
							<div>
								<input type="hidden" id="TargetType" />
								<input type="hidden" id="TargetCode" />
								<input type="hidden" id="TargetMultiName" value="" />
								<input type="text" readonly id="TargetName" value="" class="name"/>
								<a onclick="openOrgMap();" class="btnTypeDefault"><spring:message code='Cache.btn_OrgMDM' /></a><a onclick="addShareMineData();" class="btnTypeDefault btnBlueBoder "><spring:message code='Cache.lbl_Add' /></a><!-- 조직도 --><!-- 추가 -->
							</div>
							<div class="selectCalView">
								<select id="selectNotice"></select>
								<div id="divCalendar" class="dateSel type02">
									<input class="adDate" type="text" id="StartDate" date_separator="." readonly=""> - <input id="EndDate" date_separator="." kind="twindate" date_startTargetID="StartDate" class="adDate" type="text" readonly="">
								</div>											
							</div>
						</div>
					</div>
				</div>
				<div class="middle">
					<div class="schShareList" >
						<ul id="shareList">
						</ul>
						<input type="hidden" id="shareCodeList" value="" />
					</div>
				</div>
				<div class="bottom">
					<a onclick="Common.Close();" class="btnTypeDefault btnTypeBg"><spring:message code='Cache.btn_Confirm' /></a><a onclick="deleteShareMine();" class="btnTypeDefault"><spring:message code='Cache.btn_delete' /></a><!-- 확인 --><!-- 삭제 -->
				</div>
			</div>
		</div>
	</div>
</body>

<script>
var userCode = Common.getSession("USERID");

initContent();

function initContent(){
	getcal();
	getShareList();
}

//캘린더초기값 처음페이지 로딩시 1주 셋팅
function getcal(){
	var sDate = new Date();
	var eDate = new Date();
	eDate.setDate(sDate.getDate()+(1*7));
	
	$('#StartDate').val(sDate.format('yyyy.MM.dd'));
	$('#EndDate').val(eDate.format('yyyy.MM.dd'));
	$('#selectNotice').coviCtrl("setDateInterval", $('#StartDate'), $('#EndDate'), '', { initVal: '1W' });	
}

// 개인일정 공유자 조회하기
function getShareList(){
	var targetCodeArr = new Array();
	var shareIDArr = new Array();
	var sDateArr = new Array();
	var eDateArr = new Array();
	
	$.ajax({
		url: "/groupware/schedule/getShareMine.do",
		type: "POST",
		data: {},
		success: function (res) {
			var shareListHtml = "";
			$(res.list).each(function(){
				var shareID = this.ShareID;
				var targetCode = this.TargetCode;
				var targetName = this.TargetName;
				var startDate = this.StartDate == undefined ? "" : this.StartDate;
				var endDate = this.EndDate == undefined ? "" : this.EndDate;
				startDate = CFN_TransLocalTime(startDate).split(' ')[0];
				endDate = CFN_TransLocalTime(endDate).split(' ')[0];
				
				shareListHtml += '<li class="listCol" id="targetData_'+shareID+'">';
				shareListHtml += '<div>';
				shareListHtml += '<div class="chkStyle04 chkType01">';
				shareListHtml += '<input type="checkbox" id="allSV'+shareID+'" name="allSV"><label for="allSV'+shareID+'"><span></span></label>';
				shareListHtml += '</div>';
				shareListHtml += '</div>';
				shareListHtml += '<div type="code"><span targetCode="'+targetCode+'">'+targetName+'('+targetCode+')</span></div>';
				
				if(startDate != "" || endDate != "")
					shareListHtml += '<div type="date"><span>'+startDate.replaceAll("-", ".")+' - '+endDate.replaceAll("-", ".")+'</span></div>';
				
				targetCodeArr.push(targetCode);
				shareIDArr.push(shareID);
				sDateArr.push(startDate.replaceAll("-", "."));
				eDateArr.push(endDate.replaceAll("-", "."));
					
				shareListHtml += '<div><a onclick="showliShareMore(this, '+shareID+');" class="btnModifi off"><spring:message code="Cache.btn_Edit" /></a></div>';	//수정
				shareListHtml += '</li>';
				
				shareListHtml += '<li class="shreDateMore" id="targetMore_'+shareID+'" style="display:none">';
				shareListHtml += '<div id="simpleSchDateCon_'+shareID+'" class="selectCalView"></div>';
				shareListHtml += '</li>';
			});
			$("#shareList").html(shareListHtml);
			
			var timeInfos = {
				width : "80",
				H : "",
				W : "1,2", //주 선택
				M : "1,2", //달 선택
				Y : "1" //년도 선택
			};
			
			var initInfos = {
				useCalendarPicker : 'Y',
				useTimePicker : 'N',
				useBar : 'N',
				useSeparation : 'N',
				minuteInterval : 5,
				timePickerwidth : '50',
				height : '200',
				use59 : 'Y'
			};
			
			$(".shreDateMore").each(function(idx, item){
				coviCtrl.renderDateSelect("simpleSchDateCon_"+shareIDArr[idx], timeInfos, initInfos);
				$(item).find("#simpleSchDateCon_"+shareIDArr[idx]+"_StartDate").val(sDateArr[idx]);
				$(item).find("#simpleSchDateCon_"+shareIDArr[idx]+"_EndDate").val(eDateArr[idx]);
			});
			
			$("#shareCodeList").val(targetCodeArr.join(";"));
		},
		error:function(response, status, error){
			CFN_ErrorAjax("/groupware/schedule/getShareMine.do", response, status, error);
		}
	});
}

// 수정 펼치고 접기
function showliShareMore(obj, shareID){
	if($(obj).hasClass("off")){
		$(obj).html("<spring:message code='Cache.lbl_Confirm' />");	//확인
		$(obj).removeClass("off");
		$(obj).addClass("on");
		
		$("#targetMore_"+shareID).show();
		coviInput.setDate();
	}else{
		$(obj).html("<spring:message code='Cache.btn_Edit' />");	//수정
		$(obj).removeClass("on");
		$(obj).addClass("off");
		
		$("#targetMore_"+shareID).hide();
		
		var targetCode = $(obj).parent().parent().find("div[type=code]").find("span").attr("targetCode");
		var startDate = $("#targetMore_"+shareID).find("#simpleSchDateCon_"+shareID+"_StartDate").val();
		var endDate = $("#targetMore_"+shareID).find("#simpleSchDateCon_"+shareID+"_EndDate").val();
		
		//확인 버튼에 대한 update 진행
		$.ajax({
		    url: "/groupware/schedule/modifyShareMine.do",
		    type: "POST",
		    data: {
				"TargetCode": targetCode,
				"StartDate": startDate,
				"EndDate": endDate
			},
		    success: function (res) {
	            Common.Inform("<spring:message code='Cache.msg_117'/>", "Information", function(){		//성공적으로 저장하였습니다.
	            	getShareList();
	            });
	        },
	        error:function(response, status, error){
				CFN_ErrorAjax("/groupware/schedule/modifyShareMine.do", response, status, error);
			}
		});
	}
}

// 개인일정 공유자 조직도
function openOrgMap(){
	parent._CallBackMethod2 = setOrgMapTargetData;
	parent.Common.open("","orgmap_pop","<spring:message code='Cache.lbl_apv_org'/>","/covicore/control/goOrgChart.do?callBackFunc=_CallBackMethod2&type=B9&treeKind=Group","1060px","580px","iframe",true,null,null,true);
}

function setOrgMapTargetData(data){
	
	var dataObj = $.parseJSON(data);
	var peopleCnt=$$(dataObj).find("item").find("itemType").length;
	
	var userCode="";
	var userName="";
	var userType="";
	
	var user=["","","",""];
	
	for(i=0; i<peopleCnt;i++){
		userCode=$$(dataObj).find("item").concat().eq(i).attr("AN");
		userName=$$(dataObj).find("item").concat().eq(i).attr("DN");
		userType=$$(dataObj).find("item").concat().eq(i).attr("itemType");
		
		if(i!=peopleCnt-1){
			user[0]+=userType+",";
			user[1]+=userCode+",";
			user[2]+=userName+",";
			user[3]+=CFN_GetDicInfo(userName)+",";
		}else{
			user[0]+=userType;
			user[1]+=userCode;
			user[2]+=userName;
			user[3]+=CFN_GetDicInfo(userName);
		}
	}	
	
	$("#TargetType").val(user[0]);
	$("#TargetCode").val(user[1]);
	$("#TargetMultiName").val(user[2]);
	$("#TargetName").val(user[3]);
	$("#TargetName").attr('title',user[3]);
	
}

// 개인일정 공유자 추가하기
function addShareMineData(){
	var specifierCode = userCode;
	var specifierName = Common.getSession("USERNAME");		// TODO
	var registerCode = userCode;
	
	//공유 대상자 데이터 세팅
	var targetType = $("#TargetType").val().split(',');
	var targetCode = $("#TargetCode").val().split(',');
	var targetName = $("#TargetMultiName").val().split(',');
	var startDate = $("#StartDate").val();
	var endDate = $("#EndDate").val();
	
	var gBaseConfigFolderID = Common.getBaseConfig("SchedulePersonFolderID");
	
	if(startDate > endDate){
		Common.Warning(Common.getDic("msg_StartDateCannotAfterEndDate"));
		return false;
	}

	if(targetCode != "" && targetName !=""){
		
		if(targetCode == specifierCode){
			Common.Inform("<spring:message code='Cache.CPMail_approvalAddNotSelf' />"); // 자기 자신은 추가할 수 없습니다.
			
			$("#TargetType").val("");
			$("#TargetCode").val("");
			$("#TargetName").val("");
			$("#TargetMultiName").val("");
			$("#TargetName").removeAttr("title")
			
			return false;
		}else if($("#shareCodeList").val().indexOf(targetCode) > -1){
			Common.Inform("<spring:message code='Cache.CPMail_approvalAlreadyUser' />"); // 이미 추가된 사용자입니다.
			
			$("#TargetType").val("");
			$("#TargetCode").val("");
			$("#TargetName").val("");
			$("#TargetMultiName").val("");
			$("#TargetName").removeAttr("title")
			
			return false;
		}
		
		for(i=0;i<targetType.length;i++){
			var targetDataArr = new Array();
			var targetObj = {};
			$$(targetObj).append("TargetType", targetType[i]);
			$$(targetObj).append("TargetCode", targetCode[i]);
			$$(targetObj).append("TargetName", targetName[i]);
			
			$$(targetObj).append("StartDate", startDate);
			$$(targetObj).append("EndDate", endDate);
			
			//공유 일정에 대한 권한
			$$(targetObj).append("ObjectID", gBaseConfigFolderID);		// 내 일정의 FolderID 조회
			$$(targetObj).append("ACL", "_____VR");			// 조회,읽기 권한만
			
			targetDataArr.push(targetObj);
			
			$.ajax({
			    url: "/groupware/schedule/saveAdminShareData.do",
			    type: "POST",
			    data: {
			    	"mode":"I",
					"TargetDataArr":JSON.stringify(targetDataArr),
					"SpecifierCode":specifierCode,
					"SpecifierName":specifierName,
					"RegisterCode":registerCode
				},
			    success: function (res) {
		            Common.Inform("<spring:message code='Cache.msg_117'/>", "Information", function(){		//성공적으로 저장하였습니다.
		            	getShareList();
		            });
		            
		        },
		        error:function(response, status, error){
					CFN_ErrorAjax("/groupware/schedule/saveAdminShareData.do", response, status, error);
				}
			});
		}
	}else{
		Common.Warning("<spring:message code='Cache.msg_mustAddUser'/>");		//사용자를 지정해주시기 바랍니다.
	}
}

//삭제
function deleteShareMine(){
	var shareIDs = ";";
	
	$("[id^=allSV]").each(function(){
		if($(this).is(":checked"))
			shareIDs += $(this).attr("id").replace("allSV", "") + ";";
	});
	
	$.ajax({
	    url: "/groupware/schedule/removeShareMine.do",
	    type: "POST",
	    data: {
	    	"ShareIDs" : shareIDs
		},
	    success: function (res) {
	    	if(res.status == "SUCCESS"){
		    	Common.Inform("<spring:message code='Cache.msg_deleteSuccess'/>", "", function(){			//성공적으로 삭제하였습니다.
		    		getShareList();
		    	});
	    	} else {
				Common.Error("<spring:message code='Cache.msg_apv_030'/>");		// 오류가 발생했습니다.
			}
	       },
	       error:function(response, status, error){
			CFN_ErrorAjax("/groupware/schedule/removeShareMine.do", response, status, error);
		}
	});
}
</script>