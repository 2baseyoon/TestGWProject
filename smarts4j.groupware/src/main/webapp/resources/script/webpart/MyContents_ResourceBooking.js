/**
 * myContents - 마이 컨텐츠 - 자원예약현황
 */
var myContents_ResourceBooking ={
	bookingDate :  "",
	resourceFolderID : "",
	init: function (data,ext){
		this.bookingDate = new Date(CFN_GetLocalCurrentDate("yyyy/MM/dd HH:mm:ss"));
		$("#myContents_ResourceBooking_bookingDate").text(this.bookingDate.format("yyyy.MM.dd E"));
		
		resourceUser.setAclEventFolderData();
		
		if($$(resAclArray).find("view").concat().length > 0){
			$$(resAclArray).find("view").concat().each(function(i, obj){
				if( !["Folder","Root"].includes($$(obj).attr("FolderType")) ){
					myContents_ResourceBooking.resourceFolderID += $$(obj).attr("FolderID") + ";";
				}
			});
		}
		
		myContents_ResourceBooking.getBookingList();
	},
	getBookingList : function(){
		var strDate = this.bookingDate.format("yyyy-MM-dd");
		
		//폴더 별 예약 목록이 아닌 전체 예약 목록 조회를 위해 mode 'D'가 아닌 'M'으로 사용
		$.ajax({
		    url: "/groupware/resource/getBookingList.do",
		    type: "POST",
		    data: {
		    	"mode" : "M", 
		    	"FolderID" : myContents_ResourceBooking.resourceFolderID,
		    	"StartDate" : CFN_TransServerTime(strDate + " 00:00:00"),
		    	"EndDate" : CFN_TransServerTime(strDate + " 23:59:59"),
		    	"hasAnniversary" : "N",
				"ApprovalState": 'Approval;'
			},
		    success: function (res) {
		    	if(res.status == "SUCCESS"){
		    		if(res.data.bookingList.length > 0){
			    		var sHtml = "";
			    		
			    		$(res.data.bookingList).each(function(idx, obj){
			    			var readClass = "unread";
			    			var today = new Date(CFN_GetLocalCurrentDate("yyyy/MM/dd HH:mm:ss"));
			    			var endDate = new Date(replaceDate(obj.EndDateTime));
			    			if(today > endDate){
			    				readClass = "read";
			    			}
			    			
			    			var sTime = CFN_TransLocalTime(obj.StartDate + " " + obj.StartTime, "HH:mm");
			    			var eTime = CFN_TransLocalTime(obj.EndDate + " " + obj.EndTime, "HH:mm");
			    			var sDate = CFN_TransLocalTime(obj.StartDate + " " + obj.EndTime, "yyyy-MM-dd");
			    			var eDate = CFN_TransLocalTime(obj.EndDate + " " + obj.EndTime, "yyyy-MM-dd");			    			
			    			var startTime = (strDate > sDate) ? '00:00' : sTime;
			    			var endTime = (strDate < eDate) ? '23:59' : eTime;

			    			sHtml += '<li  class="' + readClass + '">';
			    			sHtml += '	<a href="#" onclick="resourceUser.goDetailViewPage(\'Webpart\', \''+ obj.EventID +'\', \''+ obj.DateID +'\', \''+ obj.RepeatID +'\', \''+ obj.IsRepeat +'\', \''+ obj.ResourceID +'\');">';
			    			sHtml += '		<span class="boxDivTit">' + startTime + ' ~ ' + endTime + '</span>';
			    			sHtml += '		<span class="resourceTit">' + obj.FolderName + '</span>';
			    			sHtml += '	</a>';
			    			sHtml += '</li>';
			    		});
			    		
			    		$("#myContents_ResourceBooking_List").empty().html(sHtml)
			    											.parents(".pieceCont").css({padding:""});;
		    		}else{
		    			myContents_ResourceBooking.emptyList();
		    		}
		    	}
	        },
	        error:function(response, status, error){
				CFN_ErrorAjax("/groupware/resource/getBookingList.do", response, status, error);
			}
		});
	}, 
	changeDate: function(type){
		var addDay = (type == "prev" ? -1 : 1);

		//기준 날짜 변경
		this.bookingDate = schedule_AddDays(this.bookingDate, addDay);

		//상단 타이틀 변경
		$("#myContents_ResourceBooking_bookingDate").text(this.bookingDate.format("yyyy.MM.dd E"));
		
		//목록 조회
		myContents_ResourceBooking.getBookingList();
		
	},
	// 목록 없음 표시
	emptyList:function(){
		$("#myContents_ResourceBooking_List").parents(".pieceCont").css({padding:"0px"});
		myContents.emptyList("#myContents_ResourceBooking_List");
	}
	
}
