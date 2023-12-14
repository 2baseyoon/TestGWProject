
var time_diff;

var hisSeq;

var myContents_Attendance = {
		time_diff : 0,
		init: function (data,ext){
			myContents_Attendance.getBaseData()
		},
		
		getBaseData : function (){
			myContents_Attendance.getServerData();	/* 시간 조회 */
		},

		getServerData : function(){
			$.ajax({
				type:"POST",
				url:"/groupware/attendUserSts/getMyContentWebpartInfo.do",
				success:function(data) {
					var serverTimeStr = data.serverTime;
					var spServerTime = serverTimeStr.split("/");
					var serverTime = new Date(spServerTime[0],spServerTime[1]-1,spServerTime[2],spServerTime[3],spServerTime[4],spServerTime[5]);

					var clientTime = new Date();
					myContents_Attendance.time_diff = serverTime.getTime() - clientTime.getTime();
					
					var month = serverTime.getMonth()+1;
					var day = serverTime.getDate();
					var week = myContents_Attendance.getDayOfWeek(clientTime);
					
					var monthStr = "<spring:message code='Cache.lbl_month'/>";
					var dayStr = "<spring:message code='Cache.lbl_day'/>";

					$("#webpartAttDate").html(month+monthStr+day+dayStr+" ("+week+")");
					// 21.10.01, 기존 문자열 덧셈이 되어 숫자형 덧셈으로 변경.
					var exHoSumTime = parseInt(data.userAtt.ExtenAc) + parseInt(data.userAtt.HoliAc);
					var weekExHoTime = data.userAtt.WorkTime - data.userAtt.FixWorkTime;
					$("#exBaseTime").html("("+Common.getBaseConfig("AttendanceWeekWorkingTime")+"<spring:message code='Cache.lbl_att_baseExtime'/>)");
					// 21.10.01, 기존 분단위로 표현되어 시간단위로 변경.
					exHoSumTime = AttendUtils.convertSecToStr(exHoSumTime, "H").replace("h", "");
					exHoSumTime = exHoSumTime.split("h")[0][0];
					var cntStr = "<span class='tx_exst_cnt_on' >"+exHoSumTime+"</span><span class='tx_exst_cnt_bar'>/</span>"+weekExHoTime;
					$(".tx_exst_cnt").html(cntStr);
					
					myContents_Attendance.getCommuSts();
					myContents_Attendance.getNowDate();
					
				}
			});
			
			myContents_Attendance.getNowDate();
		}, 
		
		getNowDate : function(){
			var now_client_time = new Date();
			var now_server_time = new Date(now_client_time.getTime() + myContents_Attendance.time_diff);

			var timeFormat = myContents_Attendance.addZeros(now_server_time.getHours(),2) + ":" + myContents_Attendance.addZeros(now_server_time.getMinutes(),2) + ":" + myContents_Attendance.addZeros(now_server_time.getSeconds(),2) ;
			$("#webpartAttTime").html(timeFormat);
			
			setTimeout("myContents_Attendance.getNowDate()",1000);
		},
		
		addZeros : function(num, digit) { // 자릿수 맞춰주기
			  var zero = '';
			  num = num.toString();
			  if (num.length < digit) {
			    for (var i = 0; i < digit - num.length; i++) {
			      zero += '0';
			    }
			  }
			  return zero + num;
		} ,
		
		getDayOfWeek : function (paramDate){
			var week = [
			              "<spring:message code='Cache.lbl_att_806_s_1_sun'/>"
			            , "<spring:message code='Cache.lbl_att_806_s_1_mon'/>"
			            , "<spring:message code='Cache.lbl_att_806_s_1_tue'/>"
			            , "<spring:message code='Cache.lbl_att_806_s_1_wed'/>"
			            , "<spring:message code='Cache.lbl_att_806_s_1_thu'/>"
			            , "<spring:message code='Cache.lbl_att_806_s_1_fri'/>"
			            , "<spring:message code='Cache.lbl_att_806_s_1_sat'/>"
			            ];
			var dayOfWeek = week[paramDate.getDay()];
			return dayOfWeek;
		},

		getCommuSts : function(){ 
			var data = {
					commuteChannel : "W"
				}
			$.ajax({
				type:"POST",
				data:data,
				url:"/groupware/attendCommute/getCommuteBtnStatus.do",
				success:function (data) {
					if(data.result=="ok"){
						var workHtml =  $('<a />', {
							class : "att_btn",
							style:'width:100%'
							});

						
						$("#btnSts").removeAttr("style");
						$("#btnSts").html(workHtml);
						$("#btnSts a").html(Common.getDic(data.btnLabel));
						$("#btnSts a").off('click');
						if (data.commuteStatus=="S"){
							$("#btnSts a").addClass('btn_in');
						}else{
							$("#btnSts a").addClass('btn_out');
						}
						
						$("#btnSts a").on('click',function(){
							AttendUtils.openCommuteAlram(data.commuteStatus,data.targetDate);
						});
						
						$("#atSts").removeAttr("style");
						var stsStr = Common.getDic(data.atSts);
						if(data.commuteStatus=="E"){
							stsStr +=" : "+data.startTime; 
						}else if(data.commuteStatus=="SE"){ 
							stsStr +=" : ["+data.targetDate+"]"+data.startTime;
						}else if(data.commuteStatus=="EE"){
							stsStr +=" : "+data.endTime; 
						}else if(data.commuteStatus=="O"){
							stsStr +=" : "+data.startTime+"~"+data.endTime; 
							$("#btnSts a").off('click');
						}
						$("#atSts").html(stsStr);
					}
				}	
			});
		}/*,
		setAtt : function (st,hs){
			//myContents_Attendance.setCommutingSts(st,hs);
			AttendUtils.openCommuteAlram(st,data.targetDate);
			openCommutingAlram(hs,st);
			hisSeq = hs;
		},
		setCommutingSts : function(st,hs){
			Common.Loading();
			var params = {
					"CommuteYn":st 
					,"HisSeq" : hs
					,"Channel" : "W"
			}
			
			$.ajax({
				type:"POST",
				dataType : "json",
				data: params,
				url:"/groupware/layout/setAttStatus.do",
				success:function (data) {
					if(data.status =="SUCCESS"){
						myContents_Attendance.getBaseData();
					}else if(data.status =="FAIL"){
						Common.Warning(data.msg);
					}
					
					Common.AlertClose();
				},
				error:function(e){
					Common.AlertClose();
				}
			});
		}*/
		
}
/*
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

function setCommutingSts(st){
	Common.Loading();
	var params = {
			"CommuteYn":st 
			,"HisSeq" : hisSeq
			,"Channel" : "W"
	}
	var msg = "";
	if(st=="Y"){
		msg = Common.getDic('lbl_att_left_sts_checkin');	//출근완료	
	}else if(st=="N"){
		msg = Common.getDic('lbl_att_left_sts_checkout');	//퇴근완료
	}
	
	$.ajax({
		type:"POST",
		dataType : "json",
		data: params,
		url:"/groupware/layout/setAttStatus.do",
		success:function (data) {
			if(data.status =="SUCCESS"){
				myContents_Attendance.getBaseData();
				Common.Inform(msg,"Information",function(){ 
					parent.Common.close("CommuAlram");
	    		}); 
			}else if(data.status =="FAIL"){
				myContents_Attendance.getBaseData();
				Common.Warning(data.msg);
			}
			Common.AlertClose();
		},error:function(e){
			Common.Warning(e);
			Common.AlertClose();
		}
	});
}*/