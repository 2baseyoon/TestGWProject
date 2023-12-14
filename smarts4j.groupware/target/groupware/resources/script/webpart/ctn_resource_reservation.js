/**
 * ctnResourceReservation - 자원 예약 현황
 */
var ctnResourceReservation = {
	
	reserveDate :  ""
	, resourceID : ""
	, dateNow : ""
	, init: function (data, ext, pType, pWebpartID){
		let $webpart = $("#"+pWebpartID);
		resourceUser.setAclEventFolderData(); 	// get authority.
		
		if($$(resAclArray).find("view").concat().length > 0){ 		// resourceID list from authority.
			$$(resAclArray).find("view").concat().each(function(i, obj){
				if( !["Folder","Root"].includes($$(obj).attr("FolderType")) ){
					ctnResourceReservation.resourceID += $$(obj).attr("FolderID") + ";";
				}
			});
		}
		
		ctnResourceReservation.reserveDate = new Date(CFN_GetLocalCurrentDate("yyyy/MM/dd HH:mm:ss"));
		ctnResourceReservation.dateNow = ctnResourceReservation.reserveDate;
		$webpart.find(".toolbar time").text(ctnResourceReservation.reserveDate.format("yyyy.MM.dd E"));
		
		$webpart.find(".toolbar button").on("click", function() { 	// prev, next btn event.
			let btnType = $(this).attr("data-icon");
			ctnResourceReservation.exchangeDate(btnType, pWebpartID);
		});
		
		// get Data.
		ctnResourceReservation.getReservedList(ctnResourceReservation.dateNow, pWebpartID);
	}
	
	, getReservedList : function(pDate, pWebpartID) {
		let $webpart = $("#"+pWebpartID);
		
		let strDate = pDate.format("yyyy-MM-dd");
		let params = {
			"mode" : "M"
			, "FolderID" : ctnResourceReservation.resourceID
			, "StartDate" : CFN_TransServerTime(strDate + " 00:00:00")
		    , "EndDate" : CFN_TransServerTime(strDate + " 23:59:59")
		    , "hasAnniversary" : "N"
		};
		
		$.ajax({
			url : "/groupware/resource/getBookingList.do"
			, type : "POST"
			, data : params
			, success: function (response) {
				if (response?.status == "SUCCESS") {
					$webpart.find("ul.content_list").empty();
					
					if (response?.data?.bookingList.length > 0) {
						$webpart.find("div[data-simplebar]").attr("hidden", false);
						$webpart.find(".widget_empty").attr("hidden", true);
						let strHtml = "";
						
						$(response.data.bookingList).each(function(idx, obj) {
							let sTime = CFN_TransLocalTime(obj.StartDate + " " + obj.StartTime, "HH:mm");
			    			let eTime = CFN_TransLocalTime(obj.EndDate + " " + obj.EndTime, "HH:mm");
			    			let sDate = CFN_TransLocalTime(obj.StartDate + " " + obj.EndTime, "yyyy-MM-dd");
			    			let eDate = CFN_TransLocalTime(obj.EndDate + " " + obj.EndTime, "yyyy-MM-dd");	
							let startTime = (strDate > sDate) ? '00:00' : sTime;
							let endTime = (strDate < eDate) ? '23:59' : eTime;
							strHtml += '<li>';
							
							if ( ctnResourceReservation.dateNow > new Date(replaceDate(obj.EndDateTime)) ) { 	// having class past
								strHtml += '	<a href="#" class="past" onclick="resourceUser.goDetailViewPage(\'Webpart\', \''+ obj.EventID +'\', \''+ obj.DateID +'\', \''+ obj.RepeatID +'\', \''+ obj.IsRepeat +'\', \''+ obj.ResourceID +'\');">';
							} else {
								strHtml += '	<a href="#" onclick="resourceUser.goDetailViewPage(\'Webpart\', \''+ obj.EventID +'\', \''+ obj.DateID +'\', \''+ obj.RepeatID +'\', \''+ obj.IsRepeat +'\', \''+ obj.ResourceID +'\');">';
							}
							strHtml += '<time>'+ startTime + ' ~ ' + endTime + '</time>';
							strHtml += '<span>' + obj.FolderName + '<span>';
							strHtml += '</a></li>';
							$webpart.find("ul.content_list").html(strHtml);
						});
					} else { 	// data is 0.
						$webpart.find("div[data-simplebar]").attr("hidden", true);
						$webpart.find(".widget_empty").attr("hidden", false);
					}
				}
			}
			, error:function(response, status, error){
				CFN_ErrorAjax("/groupware/resource/getBookingList.do", response, status, error);
			}
		});
	}

	, exchangeDate : function(pType, pWebpartID) { 	// prev, next btn event.
		let diffDay = (pType === "prev") ? -1 : 1;
		let $webpart = $("#"+pWebpartID);
		
		ctnResourceReservation.reserveDate = schedule_AddDays(ctnResourceReservation.reserveDate, diffDay)
		$webpart.find(".toolbar time").text(ctnResourceReservation.reserveDate.format("yyyy.MM.dd E"));
		ctnResourceReservation.getReservedList(ctnResourceReservation.reserveDate, pWebpartID);
		
	}
}
