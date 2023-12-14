//출퇴근
	function setAtt(st){
		openCommutingAlram($("#hisSeq").val(),st);
	}

	function setCommutingSts(st){
		var params = {
				"CommuteYn":st
				,"HisSeq" : $("#hisSeq").val()
				,"Channel" : "W"
		}

		var msg = "";
		if(st=="Y"){
			msg = Common.getDic('lbl_att_left_sts_checkin');
		}else if(st=="N"){
			msg = Common.getDic('lbl_att_left_sts_checkout');
		}

		$.ajax({
			type:"POST",
			dataType : "json",
			data: params,
			url:"/groupware/layout/setAttStatus.do",
			success:function (data) {
				if(data.status =="SUCCESS"){
					getLeftData();
					Common.Inform(msg,"Information",function(){
						refreshList();
						parent.Common.close("CommuAlram");
		    		});
				}else if(data.status =="FAIL"){
					Common.Warning(data.msg);
					getLeftData();
				}
			}
		});
	}

	//////////////////////내근태정보 공통 script
	function attendanceClickTopButton(f){
		var g_lastURL = "";
		var url = "";
		if(f=="week"){
			sNum = 0;
			url = "/groupware/layout/attendance_AttendanceStatusWeek.do?CLSYS=attendance&CLMD=user&CLBIZ=Attendance";
		}else if(f=="month"){
			url = "/groupware/layout/attendance_AttendanceStatusMonth.do?CLSYS=attendance&CLMD=user&CLBIZ=Attendance";
		}else if(f=="dweek"){
			url = "/groupware/layout/attendance_AttendanceStatusDeWeek.do?CLSYS=attendance&CLMD=user&CLBIZ=Attendance";
		}else if(f=="dmonth"){
			url = "/groupware/layout/attendance_AttendanceStatusDeMonth.do?CLSYS=attendance&CLMD=user&CLBIZ=Attendance";
		}else if(f=="dsweek"){
			url = "/groupware/layout/attendance_AttendanceStatusDeWeekStatistics.do?CLSYS=attendance&CLMD=user&CLBIZ=Attendance";
		}else if(f=="dsmonth"){
			url = "/groupware/layout/attendance_AttendanceStatusDeMonthStatistics.do?CLSYS=attendance&CLMD=user&CLBIZ=Attendance";
		}
		CoviMenu_GetContent(url);
		g_lastURL = url;
	}


	//상세정보팝업
/* 	function openDetailDataPare(n,x,y,id) {
		openDetailPop($.param(detailDataArry[n]),x,y,id);
	} */


	function openDetailPop(d,x,y,id,ac){
		//layout/goDetailInfoPop.do
		var url = "/groupware/layout/goDetailInfoPop.do?UserCode="+id+"&TargetDate="+d;
		var titlemessage = Common.getDic("lbl_att_detail_view");  // 상세보기

		var w = 620;
		var h = 460;

		if(ac != "0"){
			w = 800;
			h = 560;
		}

		if(Common.getSession("UR_ID")!=id){
			h = h - 50;
		}

		x = setPositionXval(x,w);

		//parent.Common.open("","CommuDetailPop",titlemessage,url,w,h,"iframe",true,x,y,true);
		parent.Common.open("","CommuDetailPop",titlemessage,url,w,h,"iframe",true,null,null,true);
	/* 	CFN_OpenWindow(url,"<spring:message code='Cache.lbl_MultiLangSet'/>",500,200,""); */
	}

	//팝업 사이즈에 따라 x좌표값 지정
	function setPositionXval(x,w){
		if(x>$(window).width()-(w+30)){
			x = $(window).width()-(w+30);
		}

		return x;
	}


	//근무상태추가팝업
	function openJobpop(vDate,uc,x,y) {

		var url = "";

		var w = "";
		var h = "";

		url = "/groupware/layout/goCommuJobListPop.do?vDate="+vDate+"&p_UserCode="+uc;
		var titlemessage = Common.getDic("lbl_att_806_h_4");  // 근무상태
		w = 600;
		h = 440;

		x = setPositionXval(x,w);
		//parent.Common.open("","CommuJobPop",titlemessage,url,w,h,"iframe",true,x,y,true);
		parent.Common.open("","CommuJobPop",titlemessage,url,w,h,"iframe",true,null,null,true);
	}

	//근무제추가팝업
	function openSchPopup(s) {
		var url = "/groupware/layout/goAttSchPopup.do?SchSeq="+s;
		var titlemessage = Common.getDic("lbl_att_806_s_add");  // 근무제 등록
		parent.Common.open("","SchPop",titlemessage,url,"850px","510px","iframe",true,null,null,true);

	}


	//지정자목록팝업
	function openSchMemPopup(seq) {
		var url = "/groupware/attendSchedule/goAttSchMemListPopup.do?SchSeq="+seq
		var titlemessage = Common.getDic("lbl_att_specifier");// 지정자
		parent.Common.open("","SchMemPop",titlemessage,url,"490px","470px","iframe",true,null,null,true);

	}

	//근무상태 추가 팝업
	function openJobAddPop(){
		var url = "/groupware/layout/goCommuJobAddPop.do";
		var title =  Common.getDic("lbl_att_status_add"); // 근무상태 추가
		var w = "420";
		var h = "310";
		//parent.Common.Close("CommuJobPop");
		Common.open("","CommuJobAddPop",title,url,w,h,"iframe",true,null,null,true);
	}

	//휴일 추가 팝업
	/*function openHolidayPopup() {
		var url = "/groupware/layout/goAttHolidayPopup.do";
		var titlemessage = Common.getDic("MN_889");  //회사 휴무일 등록
		parent.Common.open("","SchMemPop",titlemessage,url,"480px","360px","iframe",true,null,null,true);

	}*/

	//출최근 알람 팝업
	function openCommutingAlram(s,st) {
		var url = "/groupware/layout/goCommutingAlram.do?HisSeq="+s+"&CommuteYn="+st;
		var titlemessage = ""  ;
		if(st=="Y"){
			 titlemessage = Common.getDic("lbl_att_commutingAlram");  //출근체크
		}else if(st=="N"){
			 titlemessage = Common.getDic("lbl_att_commutingAlramN");  //퇴근체크
		}
		parent.Common.open("","CommuAlram",titlemessage,url,"400px","280px","iframe",true,null,null,true);

	}

	//출최근 알람 팝업
	function openExHoSchPop(s) {
		var url = "/groupware/attendExHo/goExHoSchPop.do?ExHoSeq="+s;

		var titlemessage = Common.getDic("lbl_att_work")+Common.getDic("lbl_n_att_applicationTime");  //근무신청시간
		parent.Common.open("","ExHoSchPop",titlemessage,url,"300px","200px","iframe",true,null,null,true);

	}

	//지도 좌표 팝업
	function openMapPop(un,time,ip,x,y) {
		var url = "/groupware/layout/goMapPop.do?PointX="+x+"&PointY="+y+"&UserName="+escape(encodeURIComponent(un))+"&IpAddr="+ip+"&CommuTime="+time;
		var titlemessage = Common.getDic("lbl_schedule_map");//지도

/*		var params = {
				PointX : x
				,PointY : y
				,UserName : escape(encodeURIComponent("한성조"))
				,IpAddr : ip
				,CommuTime : time
		}*/
		parent.Common.open("","MapPop",titlemessage,url,"500px","600px","iframe",true,null,null,true);

	}

	//연장 휴일 근무 form open
	function openForm(formPrefix,ProcessID,paramStr){
		if(ProcessID != "null") { //null이면 양식이 없으므로 아무것도 안뜨게
			if (ProcessID != "") {
				CFN_OpenWindow('/approval/approval_Form.do?mode=COMPLETE&processID=' + ProcessID, '', 790, (window.screen.height - 100), 'scroll')
			} else {
				CFN_OpenWindow("/approval/approval_Form.do?formPrefix=" + formPrefix + "&mode=DRAFT" + paramStr, "", 790, (window.screen.height - 100), "resize", "false");
			}
		}
	}

	function onlyNumber(obj) {
	    $(obj).keyup(function () {
	        $(this).val($(this).val().replace(/[^0-9]/g, ""));
	    });
	}
	
	function onlyDecimal(obj) {
	    $(obj).keyup(function () {
	        $(this).val($(this).val().replace(/[^0-9.]/g, ""));
	    });
	}

	function formSetting(){
		//폼 오픈 버튼 활성화
		$(".exFormOpen").click(function(){
			openForm('WF_FORM_OVERTIME_WORK','','');
		});
		$(".hoFormOpen").click(function(){
			openForm('WF_FORM_HOLIDAY_WORK','','');
		});
		$(".callFormOpen").click(function(){
			openForm('WF_FORM_CALL','','');
		});
	}

	function setTodaySearch(){
		$("#inputCalendarcontrol").datepicker({
			dateFormat: 'yy-mm-dd',
			beforeShow: function(input) {
			           var i_offset = $(".calendarcontrol").offset();      // 버튼이미지 위치 조회
			           setTimeout(function(){
			              jQuery("#ui-datepicker-div").css({"left":i_offset});
			           })
			        },
			onSelect: function(dateText){
				searchList(dateText);
			}
		});
		$(".calendarcontrol").click(function(){
			$("#inputCalendarcontrol").datepicker().datepicker("show");
		});
		$(".calendartoday").click(function(){
			refreshList();
		});
	}



/*
 * EXCEL DOWNLOAD
 */
var Attendance_Excel = {

	excelDownload : function(){

	}
}



var AttendUtils ={
	openSchAllocPopup:function(seq){//사용가능 자목록팝업
		var url = "/groupware/attendSchedule/goAttSchAllocListPopup.do?SchSeq="+seq
		var titlemessage = Common.getDic("lbl_apv_jfform_07");//사용가능
		parent.Common.open("","SchAllocPop",titlemessage,url,"490px","470px","iframe",true,null,null,true);
	},
	getDeptList:function(obj, defVal, aSync, bAll, bStep){
		//$("#schList")
		if (aSync == null) aSync=true;
		$.ajax({
			url : "/groupware/attendCommon/getDeptList.do",
			type: "POST",
			async:aSync,
			dataType : 'json',
			success:function (data) {
				var subDeptList = data.deptList;
				var whole = Common.getDic("lbl_Whole");
				var subDeptOption = "";		
				if (bAll == undefined || bAll == true) subDeptOption = "<option value=''>"+whole+"</option>";		//전체
				for(var i=0;i<subDeptList.length;i++){

					subDeptOption += "<option value='"+(bStep==true?subDeptList[i].GroupPath:subDeptList[i].GroupCode)+"'>";
					var SortDepth = subDeptList[i].SortDepth;
					for(var j=1;j<SortDepth;j++) {
						subDeptOption += "&nbsp;";
					}
					subDeptOption += subDeptList[i].TransMultiDisplayName+"</option>";
				}

				obj.html(subDeptOption);
				if (defVal != ''){
					//obj.val(defVal);
					$(obj).val(defVal).prop("selected",true);
				}
			},
			error:function (error){
				//CFN_ErrorAjax("/groupware/layout/attendance_AttendanceBaseInfo.do", response, status, error);
			}
		});
	},
	getDeptStepList:function(obj, defVal, aSync, bAll, trgId){

		if (aSync == null) aSync=true;
		$.ajax({
			url : "/groupware/attendCommon/getDeptList.do",
			type: "POST",
			async:aSync,
			dataType : 'json',
			success:function (data) {
				var subDeptList = data.deptList;
				var whole = Common.getDic("lbl_Whole");
				//var subDeptOption ="<select class='selectType02'>";
				//if (bAll == undefined || bAll == true) subDeptOption = "<option value=''>"+whole+"</option>";		//전체

				var controlArry = [];
				var startIdx = subDeptList[0].SortDepth;

				for(var i=0;i<subDeptList.length;i++){
					var idx = subDeptList[i].SortDepth-startIdx;
					if (controlArry[idx] == "" || controlArry[idx] == undefined){
						controlArry[idx] = "<select class='selectType02' onchange='AttendUtils.changeDept(this,\""+trgId+"\")'>";
						if (idx>0) controlArry[idx] += "<option value=''>"+whole+"</option>";		//전체
					}
					
					controlArry[idx] += "<option value='"+subDeptList[i].GroupPath+"'>";
					var SortDepth = subDeptList[i].SortDepth;
					for(var j=1;j<SortDepth;j++) {
						controlArry[idx] += "";
					}
					controlArry[idx] += subDeptList[i].TransMultiDisplayName+"</option>";
				}
				//subDeptOption+="</select>"	;
				for (var i=0; i< controlArry.length; i++){
					obj.append(controlArry[i]+"</select>");
					
				}

				if (controlArry.length >1 ){
					obj.find("select").eq(0).css("display", "none");   
				}
				AttendUtils.changeDept(obj.find("select").eq(0),trgId);

			},
			error:function (error){
				//CFN_ErrorAjax("/groupware/layout/attendance_AttendanceBaseInfo.do", response, status, error);
			}
		});
	},
	changeDept:function(obj, trgId){
		var selVal = $(obj).val();
		
		$(obj).next("select").find("option").each(function(){ 
			if (this.value != ""){ 
				if (this.value.indexOf(selVal)==-1) {
					$(this).attr("disabled", "disabled").hide();
				}
				else{
					$(this).removeAttr("disabled").show();
				}	
			}	
		});
		
		$(obj).nextAll("select").val("");
		
		if (selVal == ""){
			var lastVal = "";
			
			$(obj).parent().find("select").each(function (i) {
				if($(this).val() != "") {
					lastVal = $(this).val(); 
				}
			});
			
			$("#"+trgId).val(lastVal);
			$("#"+trgId).trigger("change");
		} else{
			$("#"+trgId).val(selVal);
			$("#"+trgId).trigger("change");
		}
	},
	getScheduleList:function(obj, defVal, bAll){
		$.ajax({
			url : "/groupware/attendSchedule/getAttendScheduleList.do",
			type: "POST",
			async:true,
			dataType : 'json',
			success:function (data) {
				var subList = data.list;
				var whole = Common.getDic("lbl_Whole");
				var subOption = "";		
				if (bAll == undefined || bAll == true) subOption = "<option value=''>"+whole+"</option>";		//전체
				for(var i=0;i<subList.length;i++){
					subOption += "<option value='"+subList[i].SchSeq+"'>"+ subList[i].SchName+"</option>";
				}

				obj.html(subOption);
				if (defVal != ''){
					obj.val(defVal);
				}
			},
			error:function (error){
				//CFN_ErrorAjax("/groupware/layout/attendance_AttendanceBaseInfo.do", response, status, error);
			}
		});
	},
	gridToExcel:function(title, headerData, param, url){
		var this_ = this;
		Common.Confirm(Common.getDic("msg_ExcelDownMessage"), "<spring:message code='Cache.ACC_btn_save' />", function(result){
       		if(result){
       			var gridHeaderInfo = this_.getGridHeader(headerData);

				var	locationStr		= url+"?"
									+ "headerName="		+ encodeURI(gridHeaderInfo["Name"])
									+ "&headerKey="		+ encodeURI(gridHeaderInfo["Key"])
									+ "&title="			+ "sheet1"
									+ "&"+param;
				location.href = locationStr;
       		}
       	});
	},

	getGridHeader:function(headerData){
		var this_ = this;
		var gridHeaderInfo = {};
		var returnName	= "";
		var returnKey	= "";
		var returnType	= "";

	   	for(var i=0;i<headerData.length; i++){
	   	   	if(headerData[i].display != false && headerData[i].label != 'chk'){
	   	   		returnName += headerData[i].label + "†";
	   	   		returnKey += headerData[i].key + ",";
	   	   		returnType += (headerData[i].dataType != undefined ? headerData[i].dataType:"Text") + "|";
	   	   	}
		}

		gridHeaderInfo["Name"]= returnName;
		gridHeaderInfo["Key"]= returnKey;
		gridHeaderInfo["Type"]= returnType;
		return gridHeaderInfo;
	},
	convertNull:function(orgVal, repalceChar){
		if (orgVal == null) return repalceChar;
		else return orgVal;
	},
	maskTime:function(time){
		var str = XFN_ReplaceAllSpecialChars(time);

		if (str.length < 4) return str;

		if (str.length == 4)
		{
			return str.substring(0, 2) + ":" + str.substring(2, 4);
		}
		else
		{
			if (str.length < 6) time = AttendUtils.paddingStr(str, "R", "0", 6);

			return str.substring(0, 2) + ":" + str.substring(2, 4) + ":" + str.substring(4, 6);
		}
	},
	maskDate:function(time){
		if (time == null) return "";
		var str = XFN_ReplaceAllSpecialChars(time);

		if (str.length < 4) return str;

		if (str.length == 4)
		{
			return str.substring(0, 2) + "." + str.substring(2, 4);
		}
		else if (str.length == 6)
		{
			return str.substring(0, 4) + "." + str.substring(4, 6);
		}
		else if (str.length == 8)
		{
			return str.substring(0, 4) + "." + str.substring(4, 6) + "." + str.substring(6, 8);
		}
	},
	maskDateTime:function(time){
		var str = XFN_ReplaceAllSpecialChars(time);
		str= str.replace(" ", "");

		if (str.length < 4) return str;

		if (str.length == 4)
		{
			return str.substring(0, 2) + "." + str.substring(2, 4);
		}
		else if (str.length == 6)
		{
			return str.substring(0, 4) + "." + str.substring(4, 6);
		}
		else if (str.length == 8)
		{
			return str.substring(0, 4) + "." + str.substring(4, 6) + "." + str.substring(6, 8);
		}
		else if (str.length == 10){
			return str.substring(0, 4) + "." + str.substring(4, 6) + "." + str.substring(6, 8) +" " + str.substring(8, 10) ;
		}
		else if (str.length == 12){
			return str.substring(0, 4) + "." + str.substring(4, 6) + "." + str.substring(6, 8) +" " + str.substring(8, 10) + ":" + str.substring(10, 12);
		}
		else if (str.length == 14){
			return str.substring(0, 4) + "." + str.substring(4, 6) + "." + str.substring(6, 8) +" " + str.substring(8, 10) + ":" + str.substring(10, 12) + ":" + str.substring(12, 14);
		}
	},
	paddingStr:function(str, direct, chr, len)	{
		str = str + "";
		if (str.length >= len) return str;

		if (direct == "L")
			for (var i = str.length; i < len; i++)
				str = chr + str;
		else
			for (var i = str.length; i < len; i++)
				str = str + chr;

		return str;
	},
	convertStrToSec : function(sSec){
		var iSec =0;
		var sTmp = XFN_ReplaceAllSpecialChars(sSec);
		if (sTmp == "0") return 0;

		if (sTmp.length == 4)
			iSec = parseInt(sTmp.substring(0,2),10)*3600+parseInt(sTmp.substring(2,4),10)*60;
		else
			iSec = parseInt(sTmp.substring(0,2),10)*3600+parseInt(sTmp.substring(2,4),10)*60+parseInt(sTmp.substring(4,6),10);
		return iSec;
	}
	,convertSecToStr:function(iVal, sFormat)	{
		var sRet;
		var iHour	 ;
		var iMinute  ;
		var iSec     ;

		if (isNaN(iVal)  ||iVal == 0) {
			iHour = 0;
			iMinute = 0;
		}
		else{
			iHour	 = Math.floor(iVal / 60);
			iMinute  = Math.floor((iVal- 60*iHour));
			iSec     = iVal - (60*iHour) - (iMinute);
		}
		if (sFormat == "H"){
			sRet = iHour+"h ";
			if (iMinute>0 ) sRet+=iMinute+"m";
		}else if (sFormat == "h"){
			sRet = iHour+"h";
			if (iMinute>0 ) sRet+=" "+iMinute+"m";
		}else if (sFormat == "hh"){
			if(iHour>0) {
				sRet = iHour + "h";
			}else{
				sRet = "";
			}
			if (iMinute>0 ) sRet+=""+iMinute+"m";
		}else if (sFormat == "nbsp"){
			if(iHour>0) {
				sRet = iHour + "h";
			}else{
				sRet = "";
			}
			if (iMinute>0 ) sRet+=" "+iMinute+"m";
			if(sRet==""){
				sRet="&nbsp;";
			}
		}else if(sFormat == "hour"){
			sRet = iHour+"h ";
		}
		else{
			sRet =  (iHour<10?"0":"")  +   iHour + ":";
			sRet += (iMinute<10?"0":"") +  iMinute ;

		}

//		sRet += (iSec<10?"0":"")    +  iSec;
		return sRet;
	}
	,formatTime:function(sSec, sFormat){
		var sTmp = XFN_ReplaceAllSpecialChars(sSec);
		var iHour   = parseInt(sTmp.substring(0,2),10);
		var iMinute = sTmp.substring(2,4);

		if (sFormat == "AP"){
			var sAM = "AM";
			if (iHour>12) {
				iHour= String(iHour -12);
				sAM = "PM";
			}
			return AttendUtils.paddingStr(iHour,'L','0',2)+":"+AttendUtils.paddingStr(iMinute,'L','0',2)+" "+sAM;
		}
	}
	,getACL:function(menuId,objectType){ /* 사용자별 메뉴 접근 권한 확인 */
		var rVal;
		$.ajax({
			type:"POST",
			data:{
				"ObjectID" : menuId,	// 접근메뉴ID
				"ObjectType" : objectType		//S:보안 ,C:생성 ,D:삭제,M:수정,E:실행,V:조회,R:읽기
			},
			async: false,
			url:"/groupware/attendCommon/getAclMenuAuth.do",
			success : function (res) {

				if(res.result == "ok"){
					rVal = res.data;
				} /*else {
					Common.Error("<spring:message code='Cache.ACC_msg_error'/>");	//오류가 발생하였습니다. 관리자에게 문의 바랍니다.
				}*/
			},
			error : function(response, status, error){
				//CFN_ErrorAjax("/groupware/attendCommon/getAclMenuAuth.do", response, status, error);
			}
		});

		return rVal;
	}
	,openOverTimePopup:function(){//연장근무신청
		if (Common.getBaseConfig("ExtenReqMethod") == "Approval"){
			openForm('WF_FORM_OVERTIME_WORK','','');
		}
		else{
			var popupID	= "AttendReqOTPopup";
			var openerID = "AttendReq";
			var popupTit	= Common.getDic("lbl_app_approval_extention");//"<spring:message code='Cache.lbl_app_approval_extention' />";
			var popupYN		= "N";
			var callBack	= "";
			var popupUrl	= "/groupware/attendReq/AttendReqOTPopup.do?"
							+ "popupID="		+ popupID	+ "&"
							+ "openerID="		+ openerID	+ "&"
							+ "popupYN="		+ popupYN	+ "&"
							+ "callBackFunc="	+ callBack	;

			Common.open("", popupID, popupTit, popupUrl, "720px", "815px", "iframe", true, null, null, true);
		}
	}
	,openHolidayPopup:function(){//휴일근무신청
		if (Common.getBaseConfig("HoliReqMethod") == "Approval"){
			openForm('WF_FORM_HOLIDAY_WORK','','');
		}
		else{
			var popupID	= "AttendReqOTPopup";
			var openerID = "AttendReq";
			var popupTit	= Common.getDic("lbl_app_approval_holiday");//"<spring:message code='Cache.lbl_app_approval_extention' />";
			var popupYN		= "N";
			var callBack	= "";
			var popupUrl	= "/groupware/attendReq/AttendReqHolidayPopup.do?"
							+ "popupID="		+ popupID	+ "&"
							+ "openerID="		+ openerID	+ "&"
							+ "popupYN="		+ popupYN	+ "&"
							+ "callBackFunc="	+ callBack	;

			Common.open("", popupID, popupTit, popupUrl, "720px", "815px", "iframe", true, null, null, true);
		}
	}
	,openHolidayReplacementPopup:function(){//휴일대체근무신청
		openForm('HOLIDAY_REPLACEMENT_WORK','','');
	}
	,openVacationPopup:function(authType){//휴가신청
		if (Common.getBaseConfig("VacReqMethod") == "Approval" && authType !== "ADMIN"){
			openForm('WF_FORM_VACATION_REQUEST2','','');
		}
		else{
			var popupID	= "AttendReqVacationPopup";
			var openerID = "AttendReq";
			var popupTit	= authType !== "ADMIN" ? Common.getDic("MN_659") : Common.getDic("lbl_vacationCreate");//"<spring:message code='Cache.lbl_app_approval_extention' />";
			var popupYN		= "N";
			var callBack	= "";
			var popupUrl	= "/groupware/attendReq/AttendReqVacationPopup.do?"
							+ "popupID="		+ popupID	+ "&"
							+ "openerID="		+ openerID	+ "&"
							+ "popupYN="		+ popupYN	+ "&"
							+ "callBackFunc="	+ callBack	+ "&"
							+ "authType="		+ (authType ? authType : "USER");

			Common.open("", popupID, popupTit, popupUrl, "720px", "900px", "iframe", true, null, null, true);
		}
	}
	,openJobStatusPopup:function(JobStsSeq, JobStsName, ReqMethod, authType){//업무상태
		if (ReqMethod == undefined || ReqMethod == "undefined" || ReqMethod == "") ReqMethod= Common.getBaseConfig("OutReqMethod");

		if (ReqMethod == "Approval" && authType !== "ADMIN"){
			openForm('WF_OTHER_WORK','','&WorkType='+JobStsSeq+'&JobStsName='+encodeURIComponent(JobStsName));
		}
		else{
			var popupID	= "AttendReqJobPopup";
			var openerID = "AttendReq";
			var popupTit	= JobStsName + (authType !== "ADMIN" ? (ReqMethod === "None" ? Common.getDic("lbl_Registor") : Common.getDic("lbl_att_approval")) : Common.getDic("lbl_Creation"));
			var popupYN		= "N";
			var callBack	= "";
			var popupUrl	= "/groupware/attendReq/AttendReqJobPopup.do?"
							+ "popupID="		+ popupID	+ "&"
							+ "openerID="		+ openerID	+ "&"
							+ "popupYN="		+ popupYN	+ "&"
							+ "JobStsSeq="		+ JobStsSeq	+ "&"
							+ "JobStsName="		+ encodeURIComponent(JobStsName) + "&"
							+ "JobStsName2="	+ encodeURI(JobStsName)+ "&"
							+ "ReqMethod="		+ ReqMethod + "&"
							+ "callBackFunc="	+ callBack + "&"
							+ "authType="		+ (authType ? authType : "USER");

			Common.open("", popupID, popupTit, popupUrl, "720px", "865px", "iframe", true, null, null, true);
		}
	}
	,openCallPopup:function(JobStsSeq, JobStsName, callbackFunc, SelDate){//소명신청
		var reqUserCode = $('#AttendMyStstusPopup_if').contents().find('#userCode').val();
		var reqUserName = $('#AttendMyStstusPopup_if').contents().find('#at_name').text();
		
		if(callbackFunc == null || callbackFunc == undefined) callbackFunc="";
		if(SelDate == null || SelDate == undefined) SelDate = "";
		if (Common.getBaseConfig("CommuModReqMethod") == "Approval"){
			openForm('WF_FORM_CALL','','');
		}
		else{
			var popupID	= "AttendReqCallPopup";
			var openerID = "AttendReq";
			var popupTit	= Common.getDic("lbl_app_approval_call");
			var popupYN		= "N";
			var callBack	= callbackFunc;
			var popupUrl	= "/groupware/attendReq/AttendReqCallPopup.do?"
							+ "popupID="		+ popupID	+ "&"
							+ "openerID="		+ openerID	+ "&"
							+ "popupYN="		+ popupYN	+ "&"
							+ "JobStsSeq="		+ JobStsSeq	+ "&"
							+ "JobStsName="		+ JobStsName+ "&"
							+ "callBackFunc="	+ callBack	+ "&"
							+ "SelDate="        + SelDate	+ "&"
							+ "ReqUserCode="    + reqUserCode + "&"
							+ "ReqUserName="    + reqUserName  ;

			Common.open("", popupID, popupTit, popupUrl, "720px", "870px", "iframe", true, null, null, true);
		}
	}
	,openSchedulePopup:function(){//근무생성
		if (Common.getBaseConfig("WorkReqMethod") == "Approval"){
			openForm('WF_FORM_WORK_SCHEDULE','','');
		}
		else{
			var popupID	= "AttendReqSchedulePopup";
			var openerID = "AttendReq";
			var popupTit	= Common.getDic("lbl_n_att_worksch")+Common.getDic("lbl_Creation");
			var popupYN		= "N";
			var callBack	= "";
			var popupUrl	= "/groupware/attendReq/AttendReqSchedulePopup.do?"
							+ "popupID="		+ popupID	+ "&"
							+ "openerID="		+ openerID	+ "&"
							+ "popupYN="		+ popupYN	+ "&"
							+ "callBackFunc="	+ callBack	;

			Common.open("", popupID, popupTit, popupUrl, "726px", "900px", "iframe", true, null, null, true);
		}
	}
	,openMapPopup:function(openerID, mode, param){//지도생성
		var url = "/groupware/attendCommon/AttendMapPopup.do?"
					+ "popupID="		+ "AttendMapPopup"	+ "&"
					+ "openerID="		+ openerID	+ "&"
					+ "mode="+mode  ;

		if ($.type(param)=="object"){
			url+= "&Zone="+param["Zone"]
					+"&Addr="+param["Addr"]
					+"&PointX="+param["PointX"]
					+"&PointY="+param["PointY"];
		}

		var titlemessage = Common.getDic("lbl_att_map_popup");

		Common.open("","AttendMapPopup",titlemessage,url,"600px","480px","iframe",false,null,null,true);

		/*var popupID	= "AttendReqSchedulePopup";
		var openerID = "AttendReq";
		var popupTit	= Common.getDic("lbl_n_att_worksch")+Common.getDic("lbl_Creation");
		var popupYN		= "N";
		var callBack	= "";
		var popupUrl	= "/groupware/attendReq/AttendMapPopup.do?"
						+ "popupID="		+ popupID	+ "&"
						+ "openerID="		+ openerID	+ "&"
						+ "popupYN="		+ popupYN	+ "&"
						+ "callBackFunc="	+ callBack	;

		Common.open("", popupID, popupTit, popupUrl, "600px", "800px", "iframe", true, null, null, true);*/
	}
	,getWeekStart:function(d, week) {	//기준일자의 조건 요일에 해당하는  날짜 보내기
		var date = new Date(d);

	    var day = date.getDay();
	    var diff = date.getDate() - day+week;
	    
	    return new Date(replaceDate(date.setDate(diff)));
	}
	,setCalendar:function(standDate, tableId, titleId, calTbody){	//달력 그리기
		var startDateObj = new Date(replaceDate(standDate));
		var today = CFN_GetLocalCurrentDate("yyyy-MM-dd")
		var sDate = schedule_SetDateFormat(new Date(startDateObj.setMonth(startDateObj.getMonth(), 1)), '-');
		$("#"+titleId).text(sDate.substring(0,7));
		AttendUtils.makeCalTbody(titleId, calTbody);
		var eDate = schedule_SetDateFormat(new Date(startDateObj.setMonth(startDateObj.getMonth()+1, 0)), '-');
		var sunday = AttendUtils.getWeekStart(sDate,0);
		var schday = schedule_SetDateFormat(sunday, '-');
		var weekNumm = AttendUtils.getWeekOfMonth(startDateObj);
		$("#"+tableId+" tbody tr:eq(5)").show();
	    for (var i = 0; i < weekNumm; i++) {
	        for (var j = 0; j < 7; j++) {
	        	if (i==5 && j==0 && schedule_SetDateFormat(schday, '-') > eDate) 	//마지막 주가 다음달로 넘어가면 숨김처리하기
	        	{
	        		$("#"+tableId+" tbody tr:eq("+i+")").hide();
	        		break;
	        	}
	        	if (schedule_SetDateFormat(schday, '-') < sDate ||
	        			schedule_SetDateFormat(schday, '-') > eDate){
	        		$("#"+tableId+" tbody tr:eq("+i+") td:eq("+j+")").addClass("dis");
	        		$("#"+tableId+" tbody tr:eq("+i+") td:eq("+j+")").removeClass("calDate");
	        	}
	        	else{
	        		$("#"+tableId+" tbody tr:eq("+i+") td:eq("+j+")").removeClass("dis");
	        		$("#"+tableId+" tbody tr:eq("+i+") td:eq("+j+")").addClass("calDate");
	        	}
	        	//setDate
	        	if (today == schedule_SetDateFormat(schday, '-'))
		        	$("#"+tableId+" tbody  tr:eq("+i+") td:eq("+j+")").addClass("setDate");
	        	else
	        		$("#"+tableId+" tbody  tr:eq("+i+") td:eq("+j+")").removeClass("setDate");

	        	$("#"+tableId+" tbody  tr:eq("+i+") td:eq("+j+")").attr("title", schedule_SetDateFormat(schday, '-'));
	        	$("#"+tableId+" tbody  tr:eq("+i+") td:eq("+j+")").removeClass("selDate").removeClass("Bg");//.removeClass("CalWork");
	        	if (j > 0) $("#"+tableId+" tbody  tr:eq("+i+") td:eq("+j+")").removeClass("tx_sun");

	        	$("#"+tableId+" tbody  tr:eq("+i+") td:eq("+j+") .tx_day").text(schedule_SetDateFormat(schday, '-').substring(8));
	        	//$("#"+tableId+" tbody  tr:eq("+i+") td:eq("+j+") div").removeClass("Normal");
	        	$("#"+tableId+" tbody  tr:eq("+i+") td:eq("+j+") div p").text("");
	        	$("#"+tableId+" tbody  tr:eq("+i+") td:eq("+j+") div p").attr("data-map", "");
	        	schday = schedule_AddDays(schday, 1);
	        }
	    }
	}
	,goNextPrevDay:function(term, tableId, titleId){	//이전,다음달
		var standDay = replaceDate($("#"+titleId).text());
		if (standDay.length==7) standDay+="/01";

		var startDateObj = new Date(standDay);
		var standDate=  schedule_SetDateFormat(new Date(startDateObj.setMonth(startDateObj.getMonth()+term, 1)), '-');
		AttendUtils.setCalendar(standDate, tableId, titleId);
	}
	,getWeekOfMonth:function(date) {
		const startWeekDayIndex = 0; // 1 MonthDay 0 Sundays
		const firstDate = new Date(date.getFullYear(), date.getMonth(), 1);
		const firstDay = firstDate.getDay();

		let weekNumber = Math.ceil((date.getDate() + firstDay) / 7);
		if (startWeekDayIndex === 1) {
			if (date.getDay() === 0 && date.getDate() > 1) {
				weekNumber -= 1;
			}

			if (firstDate.getDate() === 1 && firstDay === 0 && date.getDate() > 1) {
				weekNumber += 1;
			}
		}
		return weekNumber;
	}
	,makeCalTbody:function(dateTitle, calBody){
		var YYYYMM = $("#"+dateTitle).text();
		var arrYYYYMM = YYYYMM.split("-");
		var YYYYMMLAST = new Date(arrYYYYMM[0],Number(arrYYYYMM[1]),0);
		var WeekNum = AttendUtils.getWeekOfMonth(YYYYMMLAST);
		var html = "";
		for(var i=0;i<WeekNum;i++){
			html += "<tr>";
			html += "	<td weekId=\"Sun\" class=\"tx_sun\"><p class=\"tx_day\"></p><div><p></p></div></td>";
			html += "	<td weekId=\"Mon\"><p class=\"tx_day\"></p><div><p></p></div></td>";
			html += "	<td weekId=\"Tue\"><p class=\"tx_day\"></p><div><p></p></div></td>";
			html += "	<td weekId=\"Wed\"><p class=\"tx_day\"></p><div><p></p></div></td>";
			html += "	<td weekId=\"Thu\"><p class=\"tx_day\"></p><div><p></p></div></td>";
			html += "	<td weekId=\"Fri\"><p class=\"tx_day\"></p><div><p></p></div></td>";
			html += "	<td weekId=\"Sat\" class=\"tx_sat\"><p class=\"tx_day\"></p><div><p></p></div></td>";
			html += "</tr>";
		}
		$("#"+calBody).html(html);
	}
	,getScheduleMonth:function(standDate, tableId, titleId, mode, calTbody) { //달력그리기
		if (mode == undefined) mode="";

		AttendUtils.setCalendar( standDate, tableId, titleId, calTbody);
		$.ajax({
			type:"POST",
			data:{"StartDate":standDate, "mode":mode, "ReqUserCode": typeof(ReqUserCode) === "string" ? ReqUserCode : Common.getSession("UR_ID") },
			url:"/groupware/attendCommon/getAttendJobCalendar.do",
			success:function (data) {
				if(data.result == "ok"){
					if (data.jobList != undefined){
						$.each(data.jobList, function(idx, obj){
							var dataMap = {
								"SchSeq": obj["SchSeq"]
								, "AttDayStartTime": obj["AttDayStartTime"]
								, "AttDayEndTime":obj["AttDayEndTime"]
								, "WorkSts":obj["WorkSts"]
								, "ConfmYn":obj["ConfmYn"]
								, "VacFlag":obj["VacFlag"]
								, "AttDayAC":obj["AttDayAC"]
								, "VacDay":obj["VacDay"]
							};

							if (mode=="CMT"){
								dataMap["StartSts"]=obj["StartSts"];
								dataMap["EndSts"]=obj["EndSts"];
								if (obj["JobDate"]<= CFN_GetLocalCurrentDate("yyyy-MM-dd") && obj["WorkSts"] == "ON" && obj["AssYn"] != 'Y' && (
										obj["StartSts"] == null || (obj["StartSts"] != null && obj["StartSts"]!="lbl_att_normal_goWork")
									|| obj["EndSts"] == null || (obj["EndSts"] != null && obj["EndSts"]!="lbl_att_normal_offWork"))){
									dataMap["Call"]=true;
									dataMap["JobDate"]=obj["JobDate"];
									dataMap["AttStartTime"]=obj["AttStartTime"];
									dataMap["AttEndTime"]=obj["AttEndTime"];

									$("#"+tableId + " td[title|='"+obj["JobDate"]+"'] div p").text(Common.getDic("lbl_n_att_callingTarget"));
								}
							}
							else{
								if (obj["WorkSts"] == "ON" && obj["VacFlag"] == 'N'){
									$("#"+tableId + " td[title|='"+obj["JobDate"]+"'] div p").text((obj.SchName!=null?obj.SchName:'')+" "+AttendUtils.maskTime(obj["AttDayStartTime"])+"~"+AttendUtils.maskTime(obj["AttDayEndTime"]));
								}
								else if (obj["VacFlag"] == "VACATION_OFF"){
									$("#"+tableId + " td[title|='"+obj["JobDate"]+"'] div p").text((obj.CodeName!=null?obj.CodeName:'')+" "+AttendUtils.maskTime(obj["AttDayStartTime"])+"~"+AttendUtils.maskTime(obj["AttDayEndTime"]));
								}
								else if (obj["VacFlag"] != 'N'){
									$("#"+tableId + " td[title|='"+obj["JobDate"]+"'] div p").text(obj["CodeName"]);
								}
								else if (obj["HoliAc"] > 0){
									$("#"+tableId + " td[title|='"+obj["JobDate"]+"'] div p").text("휴일근무");
								}
								else{
									$("#"+tableId + " td[title|='"+obj["JobDate"]+"'] div p").text(obj["WorkSts"] == "OFF"?Common.getDic("lbl_att_sch_holiday"):Common.getDic("lbl_Holiday"));
								}
							}
							
							if(dataMap["Call"] == true) {
								$("#"+tableId + " td[title|='"+obj["JobDate"]+"']").css("cursor", "pointer");
							}
							
							$("#"+tableId + " td[title|='"+obj["JobDate"]+"'] div p").attr("data-map", JSON.stringify(dataMap));
							if (obj["ConfmYn"] == "Y") {
								$("#"+tableId + " td[title|='"+obj["JobDate"]+"'] div p").append("(확)");
								$("#"+tableId + " td[title|='"+obj["JobDate"]+"']").addClass("Bg");
							}
						});
					}
					//회사 휴무일
					$.each(data.holiList, function(idx, obj){
			        	$("#"+tableId + " td[title|='"+obj["dayList"]+"']").addClass("tx_sun");
						$("#"+tableId + " td[title|='"+obj["dayList"]+"'] .tx_day").append("<span class='ml5'>"+obj["HolidayName"]+"</span>");
					});
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
	,goScheduleNextPrev:function(term, tableId, titleId, mode, calTbody){	//이전,다음달
		var standDay = replaceDate($("#"+titleId).text());
		if (standDay.length==7) standDay+="/01";

		var startDateObj = new Date(standDay);
		var standDate=  schedule_SetDateFormat(new Date(startDateObj.setMonth(startDateObj.getMonth()+term, 1)), '-');
		AttendUtils.getScheduleMonth(standDate, tableId, titleId, mode, calTbody)
	}
	,getIdleTime:function(startTime, endTime, nextDayYn, workTime, restTime){
		var today = CFN_GetLocalCurrentDate("yyyy/MM/dd");
		var acTime=0;
		var strtDate = new Date(today+" "+startTime);
		var endDate = new Date(today+" "+endTime);
		if (nextDayYn==true) endDate.setDate(endDate.getDate() + 1);

		var gapTime = (endDate.getTime()-strtDate.getTime())/1000/60
		return AttendUtils.convertSecToStr(Math.floor(gapTime/workTime) * restTime,':');
	}
	,getIdleTime2:function(startTime, endTime, nextDayYn, workTime, restTime){ // idleTime 분으로로만 처리용 추가
		var today = CFN_GetLocalCurrentDate("yyyy/MM/dd");
		var acTime=0;
		var strtDate = new Date(today+" "+startTime);
		var endDate = new Date(today+" "+endTime);
		if (nextDayYn==true) endDate.setDate(endDate.getDate() + 1);

		var gapTime = (endDate.getTime()-strtDate.getTime())/1000/60
		//return AttendUtils.convertSecToStr(Math.floor(gapTime/workTime) * restTime,':');
		return (Math.floor(gapTime/workTime) * restTime) / 60;
	}
	,getAcTime:function(startTime, endTime, nextDayYn, idleTime){
		var today = CFN_GetLocalCurrentDate("yyyy/MM/dd");
		var acTime=0;
		var strtDate = new Date(today+" "+startTime);
		var endDate = new Date(today+" "+endTime);
		if (nextDayYn==true) endDate.setDate(endDate.getDate() + 1);

		var gapTime = (endDate.getTime()-strtDate.getTime())/1000/60;
		if (idleTime == "") idleTime ="0";
		idleTime = AttendUtils.convertStrToSec(idleTime)/60;

		if (idleTime>=gapTime){
			Common.Warning("<spring:message code='Cache.msg_CheckIdle'/>");
			return;
		}
		return AttendUtils.convertSecToStr(gapTime-idleTime,':');
	}
	,getAcTime2:function(startTime, endTime, nextDayYn, idleTime){ // idleTime 분으로만 처리하도록
		var today = CFN_GetLocalCurrentDate("yyyy/MM/dd");
		var strtDate = new Date(today+" "+startTime);
		var endDate = new Date(today+" "+endTime);
		if (nextDayYn==true) endDate.setDate(endDate.getDate() + 1);

		var gapTime = (endDate.getTime()-strtDate.getTime())/1000/60;
		if (idleTime == "") idleTime ="0";
		//idleTime = AttendUtils.convertStrToSec(idleTime)/60;

		if (idleTime>=gapTime){
			Common.Warning("<spring:message code='Cache.msg_CheckIdle'/>");
			return;
		}
		return AttendUtils.convertSecToStr(gapTime-idleTime,':');
	}
	,getAcTimeToMin:function(startTime, endTime, nextDayYn, overTime, idleTime){
		var today = CFN_GetLocalCurrentDate("yyyy/MM/dd");
		var strtDate = new Date(today+" "+startTime);
		var endDate = new Date(today+" "+endTime);
		if (nextDayYn=='Y') endDate.setDate(endDate.getDate() + 1);

		var gapTime = (endDate.getTime()-strtDate.getTime())/1000/60;
		if (idleTime == "") idleTime ="0";
		if (overTime == "") overTime ="0";

		if(gapTime >= overTime)
			gapTime = gapTime - idleTime;

		return gapTime;
	}
	,openAttStatusSetPopup:function(userCode,targetDate){	//근태현황 추가/수정 팝업
		if("ADMIN" != AttendUtils.getAttendUserAuthType(false).attendAuth){
			return false;
		}else{
			var url = "/groupware/attendUserSts/goAttUserStatusSetPopup.do";
			if(userCode!=""&&userCode!=undefined){
				url += "?userCode="+userCode+"&targetDate="+targetDate;
			}
			var titlemessage = Common.getDic("lbl_n_att_statusAddOrUpd");
			Common.open("","AttendAttStstusPopup",titlemessage,url,"499","509","iframe",true,null,null,true);
		}
	}
	,openAttJobListPopup:function(obj,targetObj,mngType){	//기타근무 리스트 레이어 팝업 (temp필요)
		var divX = $(obj).offset().right;
		var divY = $(obj).offset().top+25;	 //클릭위치 div 하단 표기

		this.hideAttJobListPopup();

		var params = {
			targetDate : $(obj).data("targetdate")
			,userCode : $(obj).data("usercode")
		};

		$.ajax({
			type:"POST",
			dataType : "json",
			data: params,
			url:"/groupware/attendUserSts/getUserJobHisInfoList.do",
			success:function (data) {
				if(data.status =="SUCCESS"){
					var jobHis = data.jobHistory;
					var jobHtml = "<div class='Workp_tit'>"+
							"<strong>"+$(obj).data("targetdate")+" </strong>"+
							"</div>"+
							"<ul class='Workp_list'>";
					for(var i=0;i<jobHis.length;i++){
						jobHtml +="<li>";
						jobHtml +="<span class='jobNm'><a href='#' onclick='parent.AttendUtils.openAttJobHisInfoPopup(\""+jobHis[i].UserCode+"\",\""+jobHis[i].JobDate+"\",\""+jobHis[i].JobStsHisSeq+"\",\""+mngType+"\",\""+jobHis[i].ProcessId+"\",\""+jobHis[i].UpdMethod+"\",\""+jobHis[i].DelMethod+"\");'>"+jobHis[i].JobStsName+"</a></span>";
						jobHtml +="<span class='jobTime'>"+jobHis[i].v_StartTime+"~"+jobHis[i].v_EndTime+" ("+jobHis[i].Etc+")</span>";
						jobHtml +="</li>";
					}
					jobHtml+="</ul>"	
					var jobClone = $("#divJobPopup").clone();
//					jobClone.css({ right: divX, top: divY });
					jobClone.attr("class","Att_JobSts_Popup");
					jobClone.find("#jobListInfo").html(jobHtml);
					$(targetObj).append(jobClone);
					/*$(obj).parent().append(jobClone);*/
					jobClone.show();
				}else{
					Common.Warning("<spring:message code='Cache.msg_sns_03'/>");
				}
			}
		});
	}
	,openAttExhoListPopup:function(obj,targetObj,gubun,mngType){
		var divX = $(obj).offset().left;
		var divY = $(obj).offset().top+25;	 //클릭위치 div 하단 표기

		AttendUtils.hideAttJobListPopup();

		var params = {
			targetDate : $(obj).data("targetdate")
			,userCode : $(obj).data("usercode")
			,jobStsName : gubun
		};

		$.ajax({
			type:"POST",
			dataType : "json",
			data: params,
			url:"/groupware/attendUserSts/getUserExhoInfoList.do",
			success:function (data) {
				if(data.status =="SUCCESS"){
					var list = data.exHoList;
					var html = "";
					for(var i=0;i<list.length;i++){
						html +="<div>";
						html +="<span class='jobTime'><a href='#' onclick='parent.AttendUtils.openAttExHoInfoPopup(\""+list[i].UserCode+"\",\""+list[i].JobDate+"\",\""+gubun+"\",\""+list[i].ExHoSeq+"\",\""+mngType+"\");'>"+list[i].StartTimeStr+"~"+list[i].EndTimeStr+"</a></span>";
						html +="</div>";
					}
					var ehClone = $("#divJobPopup").clone();
					ehClone.css({ left: divX, top: divY });
					ehClone.attr("class","Att_JobSts_Popup");
					ehClone.find("#jobListInfo").html(html);
					$(targetObj).append(ehClone);
					ehClone.show();
				}else{
					Common.Warning("<spring:message code='Cache.msg_sns_03'/>");
				}
			}
		});
	}

	,hideAttJobListPopup:function(){ //기타근무 리스트 팝업 전체 닫기
		$(".Att_JobSts_Popup").remove();
	}
	,openAttJobHisInfoPopup:function(userCode,targetDate,jobStsHisSeq,mngType, processId, updMethod, delMethod){
		if(mngType == "Y"){
			//관리자 권한이거나 본인 아니면 수정 팝업 오픈 불가
			if("ADMIN" != AttendUtils.getAttendUserAuthType(false).attendAuth){
				return false;
			}else{
				var url = "/groupware/attendUserSts/goAttJobHisPopup.do";
				if(userCode!=""&&userCode!=undefined){
					url += "?userCode="+userCode+"&targetDate="+targetDate+"&jobHisSeq="+jobStsHisSeq+"&mngType=Y";
				}

				var titlemessage = Common.getDic("lbl_n_att_jobHisUpd");
				Common.open("","AttJobHisInfoPopup",titlemessage,url,"549","398","iframe",true,null,null,true);
				this.hideAttJobListPopup();
			}
		}else{
			if (updMethod == "Approval"){	//기타근무 수정 설정 ( 전자결재 시 결재문세 명 등록 )RequestFormInstID
				openForm('WF_OTHER_WORK',processId,'&formID=353&RequestFormInstID='+processId);
			}
			else{
				var url = "/groupware/attendUserSts/goAttJobHisPopup.do";
				if(userCode!=""&&userCode!=undefined){
					url += "?userCode="+userCode+"&targetDate="+targetDate+"&jobHisSeq="+jobStsHisSeq;
				}

				var titlemessage = Common.getDic("lbl_n_att_jobHisUpd");
				Common.open("","AttJobHisInfoPopup",titlemessage,url,"549","398","iframe",true,null,null,true);
				this.hideAttJobListPopup();
			}
		}
	}
	,openAttExHoInfoPopup:function(userCode,targetDate,reqType,exHoSeq,mngType){
		if(mngType=="Y"){
			if("ADMIN" != AttendUtils.getAttendUserAuthType(false).attendAuth){
				return false;
			}else {
				var url = "/groupware/attendUserSts/goAttUserStatusExPopup.do";
				if(userCode!=""&&userCode!=undefined){
					exHoSeq = exHoSeq != undefined ? exHoSeq : '';
					url += "?userCode="+userCode+"&targetDate="+targetDate+"&reqType="+reqType+"&exHoSeq="+exHoSeq+"&mngType=Y";
				}
				var titlemessage ;
				if(reqType=="O"){
					titlemessage = Common.getDic("lbl_n_att_exUpd");
				}else if(reqType=="H"){
					titlemessage = Common.getDic("lbl_n_att_hoUpd");
				}
				Common.open("","AttExInfoPopup",titlemessage,url,"659","338","iframe",true,null,null,true);
				this.hideAttJobListPopup();
			}
		}else{
			if(reqType == "O" && Common.getBaseConfig("ExtenUpdMethod") == "Approval"){
				openForm('WF_FORM_OVERTIME_WORK','','');	//연장근무 수정 전자결재		기준일 중복 등록 가능하므로 seq로 구분하세여
			}else if(reqType == "H" && Common.getBaseConfig("HoliUpdMethod") == "Approval"){
				openForm('WF_FORM_OVERTIME_WORK','','');	//휴일근무 수정 전자결재		기준일 중복 등록 가능하므로 seq로 구분하세여
			}else{
				var url = "/groupware/attendUserSts/goAttUserStatusExPopup.do";
				if(userCode!=""&&userCode!=undefined){
					exHoSeq = exHoSeq != undefined ? exHoSeq : '';
					url += "?userCode="+userCode+"&targetDate="+targetDate+"&reqType="+reqType+"&exHoSeq="+exHoSeq;
				}
				var titlemessage ;
				if(reqType=="O"){
					titlemessage = Common.getDic("lbl_n_att_exUpd");
				}else if(reqType=="H"){
					titlemessage = Common.getDic("lbl_n_att_hoUpd");
				}

				Common.open("","AttExInfoPopup",titlemessage,url,"659","338","iframe",true,null,null,true);
				this.hideAttJobListPopup();
			}
		}


	}
	,dateToDBFormat:function(date){
		 function pad(num) {
	        num = num + '';
	        return num.length < 2 ? '0' + num : num;
	    }
	    return date.getFullYear() + '-' + pad(date.getMonth()+1) + '-' + pad(date.getDate());
	},timeToDBFormat:function(hour,min,sec,ap,fm){
		if(ap=="AM"){
			if(Number(hour)==12){
				hour = "00";
			}
		}else if(ap=="PM"){
			if(Number(hour)<12){
				hour = Number(hour)+12;
			}
		}
		var reVal = hour;

		if(min!='' && min!= null ){
			reVal += fm+( Number(min) < 10 ? "0"+Number(min) : ""+Number(min) );

			if(sec !='' && sec != null ){
				reVal += fm+( Number(sec) < 10 ? "0"+Number(sec) : ""+Number(sec) );
			}
		}

		return reVal;
	},openAttMyStatusPopup:function(userCode,targetDate,mngType){	//근태현황 추가/수정 팝업
		var url = "/groupware/attendUserSts/goAttMyStatusPopup.do?";
		if(userCode!=""&&userCode!=undefined){
			url += "userCode="+userCode+"&targetDate="+targetDate;
		}
		if (mngType == undefined) mngType="N";
		url += "&mngType="+mngType;
		var titlemessage = Common.getDic("lbl_att_attendance_sts");
		Common.open("","AttendMyStstusPopup",titlemessage,url,"629","510","iframe",true,null,null,true);
		$(".btnDropdown_layer").hide();

	},setCommute:function(channel,type,targetDate){
		var data = {
				commuteChannel : channel
				,commuteType : type
				,targetDate : targetDate
			}

		var reVal ;
		$.ajax({
			type:"POST",
			data:data,
			async:false,
			dataType:"json",
			url:"/groupware/attendCommute/setCommute.do",
			success:function (data) {
				reVal = data;
			}
		});
		return reVal;
	},openCommuteAlram:function(type,targetDate){
		//출퇴근 알림창  ( 출/퇴근 처리 후 호출 method 에 refreshList
		var url = "/groupware/attendCommute/goCommutingAlram.do?commuteType="+type+"&targetDate="+targetDate;
		var titlemessage = ""  ;
		if(type=="S"){
			 titlemessage = Common.getDic("lbl_att_commutingAlram");  //출근체크
		}else if(type=="E" || type=="SE" || type=="EE"){
			 titlemessage = Common.getDic("lbl_att_commutingAlramN");  //퇴근체크
		}
		parent.Common.open("","CommuAlram",titlemessage,url,"400px","280px","iframe",true,null,null,true);
	},getOtherJobList:function(validYn, authType){
		var params = {
			validYn : validYn
		};
		$.ajax({
			type:"POST",
			data:params,
			dataType:"json",
			url:"/groupware/attendCommon/getOtherJobList.do",
			success:function (data) {
				var jobList = data.jobList;
				var html = "";
				for(var i=0;i<jobList.length;i++){
					html += "<li><a href='#' onclick='AttendUtils.openJobStatusPopup(\""+jobList[i].JobStsSeq+"\",\""+jobList[i].JobStsName+"\",\""+jobList[i].ReqMethod+"\",\""+authType+"\");' >"+jobList[i].JobStsName+" "+(authType === "ADMIN" ? Common.getDic("lbl_Creation") : jobList[i].ReqMethod=="None" ? Common.getDic("lbl_Registor") : Common.getDic("lbl_att_approval"))+"</a></li>";
				}
				$("#jobList").append(html);
			}
		});
	},getJobList:function(jobType,targetId){	//직급 직책 리스트 조회
		var params = {
				"memberOf" : jobType
				,"companyCode":Common.getSession('DN_Code')
				,"groupType":"group"
		}

		$.ajax({
			url : "/covicore/control/getChildrenData.do",
			type: "POST",
			dataType : 'json',
			data : params,
			success:function (data) {
				var jobStr = "<option value=''>"+Common.getDic("lbl_Whole")+"</option>";
				for(var i=0;i<data.list.length;i++){
					var job = data.list[i];
					jobStr += "<option value='"+job.nodeValue+"'>"+job.nodeName+"</option>";
				}
				$("#"+targetId).html(jobStr);
			}
		});

	},openOrgChart:function(authType, callbackFun, type){//조직도 팝업
		if (type == undefined) type='D9';
		url = "/groupware/attendCommon/AttendOrgChart.do?callBackFunc="+callbackFun+"&type="+type+"&treeKind=Dept&groupDivision=Basic&authType="+authType;
		title = "<spring:message code='Cache.lbl_att_specifier_add'/>"; // 근무상태
		var w = 1000;
		if (authType == "" ||  authType == "USER"){w=1000}

		CFN_OpenWindow(url,"openGroupLayerPop",w,580,"");
	},openMapInfoPopup:function(pointX,pointY,addr){
		var url = "/groupware/attendCommon/goAttMapInfoPopup.do?"
			+ "pointx="		+ pointX	+ "&"
			+ "pointy="		+ pointY	+ "&";
		
		if (addr != null && addr!=undefined){
			url += "addr="+encodeURIComponent(encodeURIComponent(addr));
		}
		
		var titlemessage = Common.getDic("lbl_att_map_popup");
		Common.open("","AttendMapInfoPopup",titlemessage,url,"410px","276px","iframe",true,null,null,true);
	},getAttendUserAuthType:function(aSync){
		if (aSync == null) aSync=true;
		var result = {};
		$.ajax({
			url : "/groupware/attendCommon/getAttendUserAuthType.do",
			type: "POST",
			async : aSync,
			dataType : 'json',
			success:function (data) {
				result.attendAuth = data.attendAuth;
				result.jobType = data.jobType;
			}
		});

		return result;
	},Colspan:function(obj){
		var that;
		obj.find('td').each(function(col, idx) {
            if ($(this).text() != "" && $(this).html() == $(that).html()) {
                let colspan = $(that).attr("colSpan") || 1;
                colspan = Number(colspan)+1;
                 
                $(that).attr("colSpan",colspan);
                $(this).hide(); // .remove();
            } else {
                that = this;
            }
            that = (that == null) ? this : that;
        });

	}
	,openMapWorkPlacePopup:function(openerID, mode, param){//근무지 관리 화면 근무지 등록용 팝업 지도 호출 2021.08.10 nkpark
		var url = "/groupware/attendCommon/AttendMapWorkPlacePopup.do?"
			+ "popupID="+ "AttendMapPopup"	+ "&"
			+ "openerID="+ openerID	+ "&"
			+ "mode="+mode;

		var titlemessage = Common.getDic("lbl_att_map_popup");

		if ($.type(param)=="object"){
			url+="&LocationSeq="+param["LocationSeq"]
				+"&CompanyCode="+param["CompanyCode"]
				+"&WorkZoneGroupNm="+param["WorkZoneGroupNm"]
				+"&Zone="+param["Zone"]
				+"&Addr="+param["Addr"]
				+"&PointX="+param["PointX"]
				+"&PointY="+param["PointY"]
				+"&AllowRadius="+param["AllowRadius"]
				+"&ValidYn="+param["ValidYn"];

			if(param["popupTitle"]!=null && param["popupTitle"].length>0){
				titlemessage = param["popupTitle"];
			}
		}
		Common.open("","AttendMapPopup",titlemessage,url,"600px","550px","iframe",true,null,null,true);

	}
	,getWeeklyStart:function(d, week) {	//기준일자의 조건 요일에 해당하는  날짜 보내기
		var date = new Date(d);
		var bfDate = new Date(d);
		bfDate.setDate(bfDate.getDate() - 1);
		var day;
		var diff = 0;

		if(bfDate.getMonth()==date.getMonth()) {
			day = date.getDay();
			diff = date.getDate() - day + week;
		}else if((bfDate.getMonth()+1)==date.getMonth() || bfDate.getMonth() == 11) {
			var dateday = date.getDay();
			var weekdiff = week - dateday;
			if(weekdiff>0){
				day = date.getDay()+7;
			}else{
				day = date.getDay();
			}
			diff = date.getDate() - day + week;
		}
		return new Date(replaceDate(date.setDate(diff)));
	}
	,getWeeklyEnd:function(d, week) {	//기준일자의 조건 요일에 해당하는  날짜 보내기
		var date = new Date(d);
		var afDate = new Date(d);
		afDate.setDate(afDate.getDate() + 1);
		var day;
		var diff = 0;

		var dateday = date.getDay();
		var weekdiff = week - dateday;
		if(weekdiff<1) {
			day = (6 - Math.abs(weekdiff));
		}else{
			day = 0;
		}
		diff = date.getDate() + day;
		return new Date(replaceDate(date.setDate(diff)));
	},userWorkTimeOverColor:function(userWorkInfo, workTime, type) {
		var sOver = false;
		var mOver = false;
		var wOver = false;
		if(userWorkInfo!=null && userWorkInfo.length>0 && userWorkInfo.indexOf("|")>0) {
			var arrUWI = userWorkInfo.split('|');
			var psTime = Number(arrUWI[4]);
			var limitOnWeekly = psTime+Number(arrUWI[13]);
			var limitOnWeeklyTime = 0;
			var psWorkingDays = arrUWI[1];
			var psWorkingDayNum = 0;
			for (var i = 0; i < psWorkingDays.length; i++) {
				if(Number(psWorkingDays.substring(i,i+1))===1){
					psWorkingDayNum += Number(psWorkingDays.substring(i,i+1));
				}
			}
			if(limitOnWeekly>0){
				limitOnWeeklyTime = (limitOnWeekly * 60) / psWorkingDayNum;
			}
			var pDailyWT = 0;
			if (arrUWI[5] == "day") {
				pDailyWT = psTime * 60;
			} else {
				pDailyWT = (psTime * 60) / psWorkingDayNum;
			}
			var pmDailyWT = 0;
			var pmTime = Number(arrUWI[9]);
			if (arrUWI[10] == "day") {
				pmDailyWT = pmTime * 60;
			} else {
				pmDailyWT = (pmTime * 60) / psWorkingDayNum;
			}
			if (type == "D") {
				if (workTime > pDailyWT) {
					sOver = true;
				}
				if (workTime > pmDailyWT) {
					mOver = true;
				}
				if(limitOnWeekly>0 && workTime>limitOnWeeklyTime){
					wOver = true;
				}
			} else if (type == "W") {
				if (workTime > (pDailyWT * psWorkingDayNum)) {
					sOver = true;
				}
				if (workTime > (pmDailyWT * psWorkingDayNum)) {
					mOver = true;
				}
				if(limitOnWeekly>0 && workTime > (limitOnWeeklyTime * psWorkingDayNum)){
					wOver = true;
				}
			}
		}

		var color = "#111111";
		if(sOver){
			color = "#f08264";
		}
		if(mOver){
			color = "#ff0000";
		}
		if(wOver){
			color = "#fa00d0";
		}
		return color;
	},userWorkTimeOverColorV2:function(userWorkInfo, workTime, type, defualtColor) {
		var arrUWI = null;
		var sOver = false;
		var mOver = false;
		var wOver = false;
		if(userWorkInfo!=null && userWorkInfo.length>0 && userWorkInfo.indexOf("|")>0) {
			arrUWI = userWorkInfo.split('|');
			var psTime = Number(arrUWI[4]);
			var limitOnWeekly = psTime+Number(arrUWI[13]);
			var limitOnWeeklyTime = 0;
			var psWorkingDays = arrUWI[1];
			var psWorkingDayNum = 0;
			for(var i=0;i<psWorkingDays.length;i++){
				if(Number(psWorkingDays.substring(i,i+1))===1){
					psWorkingDayNum += Number(psWorkingDays.substring(i,i+1));
				}
			}
			if(limitOnWeekly>0){
				limitOnWeeklyTime = (limitOnWeekly * 60) / psWorkingDayNum;
			}
			var pDailyWT = 0;
			if(arrUWI[5]=="day"){
				pDailyWT = psTime * 60;
			}else{
				pDailyWT = (psTime * 60) / psWorkingDayNum;
			}
			var pmDailyWT = 0;
			var pmTime = Number(arrUWI[9]);
			if(arrUWI[10]=="day"){
				pmDailyWT = pmTime * 60;
			}else{
				pmDailyWT = (pmTime * 60) / psWorkingDayNum;
			}
			if(type=="D"){
				if(workTime>pDailyWT){
					sOver = true;
				}
				if(workTime>pmDailyWT){
					mOver = true;
				}
				if(limitOnWeekly>0 && workTime>limitOnWeeklyTime){
					wOver = true;
				}
			}else if(type=="W"){
				if(workTime>(pDailyWT*psWorkingDayNum)){
					sOver = true;
				}
				if(workTime>(pmDailyWT*psWorkingDayNum)){
					mOver = true;
				}
				if(limitOnWeekly>0 && workTime>(limitOnWeekly * 60)){
					wOver = true;
				}
			}
		}

		var color = defualtColor;
		if(sOver){
			color = "#f08264";
		}
		if(mOver){
			color = "#ff0000";
		}
		if(wOver){
			color = "#fa00d0";
		}
		return color;
	},userWorkTimeOverColorM:function(userWorkInfo, workTime, type, defualtColor, workDays) {
		var sOver = false;
		var mOver = false;
		var wOver = false;
		if(userWorkInfo!=null && userWorkInfo.length>0 && userWorkInfo.indexOf("|")>0) {
			var arrUWI = userWorkInfo.split('|');
			var psTime = Number(arrUWI[4]);
			var limitOnWeekly = psTime+Number(arrUWI[13]);
			var limitOnWeeklyTime = 0;
			var psWorkingDays = arrUWI[1];
			var psWorkingDayNum = 0;
			for (var i = 0; i < psWorkingDays.length; i++) {
				if(Number(psWorkingDays.substring(i,i+1))===1){
					psWorkingDayNum += Number(psWorkingDays.substring(i,i+1));
				}
			}
			if(limitOnWeekly>0){
				limitOnWeeklyTime = (limitOnWeekly * 60) / psWorkingDayNum;
			}
			var pDailyWT = 0;
			if (arrUWI[4] == "day") {
				pDailyWT = psTime * 60;
			} else {
				pDailyWT = (psTime * 60) / psWorkingDayNum;
			}
			var pmDailyWT = 0;
			var pmTime = Number(arrUWI[7]);
			if (arrUWI[8] == "day") {
				pmDailyWT = pmTime * 60;
			} else {
				pmDailyWT = (pmTime * 60) / psWorkingDayNum;
			}
			if (type == "D") {
				if (workTime > pDailyWT) {
					sOver = true;
				}
				if (workTime > pmDailyWT) {
					mOver = true;
				}
				if (limitOnWeekly>0 && workTime > limitOnWeeklyTime){
					wOver = true;
				}
			} else if (type == "W") {
				if (workTime > (pDailyWT * psWorkingDayNum)) {
					sOver = true;
				}
				if (workTime > (pmDailyWT * psWorkingDayNum)) {
					mOver = true;
				}
				if(limitOnWeekly>0 && workTime > (limitOnWeeklyTime * psWorkingDayNum)){
					wOver = true;
				}
			} else if (type == "M") {
				if (workTime > (pDailyWT * workDays)) {
					sOver = true;
				}
				if (workTime > (pmDailyWT * workDays)) {
					mOver = true;
				}
				if (limitOnWeekly>0 && workTime > (limitOnWeeklyTime * workDays)){
					wOver = true;
				}
			}
		}

		var color = defualtColor;
		if(sOver){
			color = "#f08264";
		}
		if(mOver){
			color = "#ff0000";
		}
		if(wOver){
			color = "#fa00d0";
		}
		return color;
	},attTimeHtml:function(dayTime, nightTime ){
        var html = "";
        if(dayTime!=""||nightTime!=""){
            if (dayTime != "") {
                html += dayTime;
            } else {
                html += "0h";
            }
            if (nightTime != "") {
                html += " /" + nightTime;
            } else {
                html += " /0h";
            }
        }else{
            html = "&nbsp;";
        }
        return html;
    },hhmmToFormat:function(val){
		var time = val;
		var rtn = "";
		if(time!=null && time!=""  && time.length==4){
			var h = Number(time.substr(0,2));
			if(h<12){
				if(h<10){
					rtn = "0"+h+":"+time.substr(2,2)+Common.getDic('lbl_AM');
				}else{
					rtn = ""+h+":"+time.substr(2,2)+Common.getDic('lbl_AM');
				}
			}else{
				if(h>13){
					h = h - 12;
				}
				if(h<10){
					rtn = "0"+h+":"+time.substr(2,2)+Common.getDic('lbl_PM');
				}else{
					rtn = ""+h+":"+time.substr(2,2)+Common.getDic('lbl_PM');
				}
			}
		}
		return rtn;
	},vacNameConvertor:function(ampm, vacCodeNames, type, idx){
		var rtn = "";
		if(ampm!=null&&ampm.indexOf("|")>-1&&vacCodeNames!=null&&vacCodeNames.indexOf("|")>-1){
			var arrAmPm = ampm.split('|');
			var arrVacCodeNames = vacCodeNames.split('|');
			var amCnt = 0;
			var pmCnt = 0;
			for(var i=0;i<arrVacCodeNames.length;i++){
				if(arrAmPm[i]===type){
					if(arrAmPm[i]==='AM' && amCnt===idx) {
						rtn = arrVacCodeNames[i];
						break;
					}
					if(arrAmPm[i]==='PM' && pmCnt===idx) {
						rtn = arrVacCodeNames[i];
						break;
					}
				}
				if(arrAmPm[i]=='AM'){amCnt++;}
				if(arrAmPm[i]=='PM'){pmCnt++;}
			}
		}else{
			rtn = vacCodeNames;
		}
		return rtn;
	},vacInfoPrintHtml:function(vacCodeNames, vacStartTime, vacEndTime){
		var rtn = "";
		if(vacCodeNames!=null&&vacCodeNames.indexOf("|")>-1){
			var arrVacCodeNames = vacCodeNames.split('|');
			var arrVacStartTime = vacStartTime.split('|');
			var arrVacEndTime = vacEndTime.split('|');
			for(var i=0;i<arrVacCodeNames.length;i++){
				if(i>0){rtn+="<br/>";}
				rtn += arrVacCodeNames[i];
				if(arrVacStartTime[i]!='00:00'&&arrVacEndTime[i]!='00:00'){
					rtn +=' ('+arrVacStartTime[i]+'~'+arrVacEndTime[i]+')';
				}
			}
		}else if(vacCodeNames!=null){
			rtn = vacCodeNames;
			if(vacStartTime!=null && vacEndTime!=null){
				rtn += ' ('+vacStartTime+'~'+vacEndTime+')';
			}
		}
		return rtn;
	},openUsedVacationPopup: function(vacYear, userCodes){
		var title = Common.getDic("lbl_usedVacPeopleInform"); // 연차 소진 인원 안내
		var url = "/groupware/attendReq/AttendReqUsedVacationPopup.do?"
				+ "vacYear=" + vacYear + "&"
				+ "userCodes=" + userCodes;

		Common.open("", "AttendUsedVacationPopup", title, url, "450px", "470px", "iframe", true, null, null, true);
	},openAllCommutePopup: function(){
		var title = Common.getDic("lbl_allCommuteSetting"); // 일괄출퇴근 설정
		var url = "/groupware/attendUserSts/goAttAllCommutePopup.do?";

		Common.open("", "AttendAllCommutePopup", title, url, "720px", "760px", "iframe", true, null, null, true);
	},openAllCommuteExcelPopup: function(){
		var title = Common.getDic("lbl_ExcelUpload"); // 엑셀 업로드
		var url = "/groupware/attendUserSts/goAttAllCommuteExcelUploadPopup.do?";

		Common.open("", "AttendAllCommuteExcelUploadPopup", title, url, "600px", "310px", "iframe", true, null, null, true);
	},isSendMail:function(attendMap, confMap){
		let bSendMail = false;
		if (attendMap["StartSts"] == "lbl_att_beingLate"){	//지각이면
			if (confMap["LateSendYn"] == "Y") return true;
		}
		else if (attendMap["StartSts"] == "lbl_n_att_absent"){	//결근이면
			if (confMap["AbsentSendYn"] == "Y") return true;
		}
		else if (attendMap["EndSts"] == "lbl_att_leaveErly"){	//조퇴이면
			if (confMap["EarlySendYn"] == "Y") return true;
		}
		else if (attendMap["StartSts"] == "lbl_n_att_callingTarget" ||attendMap["EndSts"] == "lbl_n_att_callingTarget"){	//소명
			if (confMap["CallingSendYn"] == "Y") return true;
		}
			
		return false;	
	},userRepJobType:function(data){
		var sRepJobTypeConfig = Common.getBaseConfig("RepJobType");
	    var sRepJobType = data.JobLevelName;
	    if(sRepJobTypeConfig == "PN"){
	       	sRepJobType = data.JobPositionName;
	    } else if(sRepJobTypeConfig == "TN"){
	    	sRepJobType = data.JobTitleName;
	    } else if(sRepJobTypeConfig == "LN"){
	    	sRepJobType = data.JobLevelName;
	    }
		if(sRepJobType == null) { sRepJobType = "" }
		return sRepJobType;
	},
	getDeptListJobType:function(obj, defVal, aSync, bStep){
		// 본부장:본인포함 하위부서, 그 외:본인 부서만
		if (aSync == null) aSync=true;
		$.ajax({
			url : "/groupware/attendCommon/getDeptListJobType.do",
			type: "POST",
			async:aSync,
			dataType : 'json',
			success:function (data) {
				var subDeptList = data.deptList;
				var subDeptOption = "";		
				for(var i=0;i<subDeptList.length;i++){

					subDeptOption += "<option value='"+(bStep==true?subDeptList[i].GroupPath:subDeptList[i].GroupCode)+"'>";
					var SortDepth = subDeptList[i].SortDepth;
					for(var j=1;j<SortDepth;j++) {
						subDeptOption += "&nbsp;";
					}
					subDeptOption += subDeptList[i].TransMultiDisplayName+"</option>";
				}

				obj.html(subDeptOption);
				if (defVal != ''){
					$(obj).val(defVal).prop("selected",true);
				}
			},
			error:function (error){
				//CFN_ErrorAjax("/groupware/layout/attendance_AttendanceBaseInfo.do", response, status, error);
			}
		});
	},
	chkJobType:function(){
		var jobTitle = Common.getSession('UR_JobTitleCode'); // 직책코드
		var AttendanceGMJobTiltleVal = Common.getBaseConfig("AttendanceGMJobTiltle").split("|");
		for (var i = 0; i < AttendanceGMJobTiltleVal.length; i++) {
			if(AttendanceGMJobTiltleVal[i] == jobTitle){
				return "DEVISION";
			}
		}
		return "USER";
	}
}

//내근태현황 페이지 삽입
function Aslide() {
	$(".ATM_filter_wrap .btn_slide_close").click(function(){
		$(this).parents('.ATM_filter_wrap').next(".ATMTop_info_wrap").toggle();
		$(this).toggleClass('btn_slide_open');
		$(this).toggleClass('btn_slide_close');
		$(this).parents().find('.cRContBottom.ATMday').toggleClass('pos');
			if($('.ATM_filter_wrap').has("btn_slide_open")) {
				$(".btn_slide_open").html('열기');
				$(".btn_slide_close").html('닫기');
			}
	});
}
