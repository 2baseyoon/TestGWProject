var executives = {
	
	commuteStatus: function(item) {
		var returnMap = {statusClass:"gray", statusName:"휴가"};

		var status = item.VacStatus != "" ? item.VacStatus : (item.AttendStatus != "" ? item.AttendStatus : item.JobStatus); 
		
		if(status == "lbl_n_att_absent") { // 결근
			returnMap["statusClass"] = "red";
			returnMap["statusName"] = "결근";
		} else if(status == "lbl_att_offWork") { // 퇴근
			returnMap["statusClass"] = "blue";
			returnMap["statusName"] = "퇴근";
		} else if(status == "lbl_att_goWork") { // 근무
			returnMap["statusClass"] = "green";
			returnMap["statusName"] = "근무";
		}
		
		return returnMap;
	},
	
	drawProfile: function(item) {
		var statusMap = executives.commuteStatus(item);

		return	$("<div>", {"class" : "executives_item"})
				.append($("<div>", {"class" : "row"})
					.append($("<div>", {"class" : "ui_avatar"})
						.append($("<img>", {"src" : coviCmn.loadImage(item.PhotoPath), "onerror": "coviCmn.imgError(this,true)"}))
					)
					.append($("<i>", {"class" : "status", "data-status-color" : statusMap["statusClass"], "text" : statusMap["statusName"]}))
				)
				.append($("<strong>", {"text" : item.DisplayName + " " + item.JobPositionName }))
				.append($("<em>", {"text" : item.DeptName}));
					
	},
	
	init: function(data, ext, caller, webpartID) {
		
		var strTarget;
		var	$targetDiv;
		
		var strTarget = "#" +webpartID + " .swiper";
		var	$targetDiv = $(strTarget);
		$.each( data[0], function(i, item) {
			if (caller == "Widget"){
				$targetDiv
				.append($("<div>", {"class" : "swiper-slide"})
					.append(executives.drawProfile(item)));				
			} else if(caller == "Contents") {
				
				var page = "executives_page" + (parseInt(i / 4) + 1).toString();
				
				if(i % 4 == 0) {
					$targetDiv.append($("<div>", {"class" : "swiper-slide", "name" : page}));
				}
				
				$("div[name=" + page + "]").append(executives.drawProfile(item));
			}
		});
		
/*		if(caller == "Widget") {
			new Swiper(".widget_executives_swiper", {
		        threshold: 5,
		        slidesPerView: 2,
		        slidesPerGroup: 2,
		        navigation: {
		            nextEl: ".widget_executives_button_next",
		            prevEl: ".widget_executives_button_prev",
		        }
			});
		} else if(caller == "Contents") {
			new Swiper(".contents_executives_swiper", {
		        navigation: {
		            nextEl: ".contents_executives_button_next",
		            prevEl: ".contents_executives_button_prev",
		        }
    		});
		}*/
		
		coviUtil.webpartDrawEmpty(data[0], caller, webpartID, Common.getDic("msg_ComNoData"));
	}
}