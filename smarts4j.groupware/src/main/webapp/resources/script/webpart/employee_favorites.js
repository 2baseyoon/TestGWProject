var employeeFavorites ={
	// 통근 상태에 따른 css 클래스 반환 함수
	commuteStatus: function(item) {
		var statusClass = "gray";
		
		var status = !!(item.VacStatus) ? item.VacStatus : (!!(item.AttendStatus) ? item.AttendStatus : item.JobStatus); 

		if(status == "lbl_n_att_absent") { // 결근
			statusClass = "red";
		} else if(status == "lbl_att_offWork") { // 퇴근
			statusClass = "blue";
		} else if(status == "lbl_att_goWork") { // 출근
			statusClass = "green";
		}
		
		return statusClass;
	},
	// 프로필 html 그려주는 함수
	drawProfile: function(item, mode) {
		var $profile = $("<a>", {"href" : "#", "class" : "favorites_item"});
			
		if(!coviUtil.isMobile()) {
			$profile.on("click", function(e){
				employeeFavorites.employeeInfo(item, mode);	
			});
		}
		
		return $profile
				.append($("<span>", {"class" : "ui_avatar"})
					.append($("<img>", {
						"src" : !coviUtil.isMobile() ? coviCmn.loadImage(item.PhotoPath) : mobile_comm_getimg(item.PhotoPath),
						"onerror": !coviUtil.isMobile() ? "coviCmn.imgError(this,true)" : "mobile_comm_imageerror(this, true)"}))
				)
				.append($("<strong>", {"text" : item.DisplayName}))
				.append($("<em>", {"class" : "status", "data-status-color" : employeeFavorites.commuteStatus(item)}));
	},
	// 메일 보내기
	sendMail: function(name, mailAddress) {
		window.open("/mail/bizcard/goMailWritePopup.do?"
			+"callMenu=" + "MailList"
			+ "&userMail=" + Common.getSession("UR_Mail")
			+ "&toUserMail="+mailAddress 
			+ "&toUserName="+name
			+ "&ccUserMail="
			+ "&ccUserName="
			+ "&bccUserMail="
			+ "&bccUserName="
			+ "&inputUserId=" + Common.getSession().DN_Code + "_" + Common.getSession().UR_Code
			+ "&popup=Y&isInbox=Y",
			"MailWriteCommonPopup", "height=800, width=1000, resizable=yes");
	},
	init: function(data, ext, caller, webPartID) {
	
		var strTarget = "#" +webPartID + " .swiper";
		var	$targetDiv = $(strTarget);

		$targetDiv.closest(".widget_card").find('.widget_more').attr("onclick", "javascript:$('.orderBusi').toggleClass('open');");
		
		if(coviUtil.isMobile()) {
			$targetDiv.closest(".widget_card").find(".widget_help").remove();
		}
		
		$.each(data[0], function(i, item) {
			if(caller == "Widget") {
				$("#widget_employee_favorites").find(".swiper-container-fade").removeClass("swiper-container-fade");
				
				$targetDiv.append($("<div>", {"class" : "swiper-slide"})
					.append(employeeFavorites.drawProfile(item, caller))
				);
			} else if(caller == "Contents") {
				var page = "employee_favorites_page" + (parseInt(i / 6) + 1).toString();
				
				if(i % 6 == 0) {
					$targetDiv.append($("<div>", {"class" : "swiper-slide", "name" : page}));
				}
				
				$("div[name=" + page + "]").append(employeeFavorites.drawProfile(item, caller));
			}
		});
		/*
		if(caller == "Widget") {
			new Swiper(".widget_employee_favorites_swiper", {
		        threshold: 5,
		        slidesPerView: 3,
		        slidesPerGroup: 3,
		        navigation: {
		            nextEl: ".widget_employee_favorites_button_next",
		            prevEl: ".widget_employee_favorites_button_prev",
		        }
		    });
		} else if(caller == "Contents") {
			new Swiper(".contents_employee_favorites_swiper", {
		        threshold: 5,
		        navigation: {
		            nextEl: ".contents_employee_favorites_button_next",
		            prevEl: ".contents_employee_favorites_button_prev",
		        }
    		});
		}*/
		
		coviUtil.webpartDrawEmpty(data[0], caller, webPartID, Common.getDic("msg_ComNoData"));

	},
	// 컨텐츠에서 임직원 클릭 시, 해당 임직원 정보 보여주는 함수
	employeeInfo: function(item, mode) {

		$("#employeeInfo" + mode).empty();
		$("#employeeInfo" + mode).removeAttr("hidden");
		
		if(mode == "Contents") {
			$("#employeeInfo" + mode)
			.append($("<div>", {"class" : "ui_avatar"})
				.append($("<img>", {"src" : coviCmn.loadImage(item.PhotoPath), "onerror": "coviCmn.imgError(this,true)"}))
			)
		}
		
		$("#employeeInfo" + mode)
		.append($("<div>", {"class" : "title"})
			.append($("<strong>", {"text" : item.DisplayName + " " + item.JobPositionName}))
			.append($("<em>", {"text" : "/" + item.DeptName}))
		)
		.append($("<div>", {"class" : "tel", "text" : item.PhoneNumber}))
		.append($("<div>", {"class" : "link"})
			.append($("<a>", {"href" : "#", "data-icon" : "chat"})
				.append($("<span>", {"text" : Common.getDic("lbl_chat")}))
			)
			.append($("<a>", {"href" : "#", "data-icon" : "mail"})
				.append($("<span>", {"text" : Common.getDic("lbl_Mail")}))
			)
		)
		.append($("<button>", {"type" : "button", "class" : "close", "data-icon" : "close"})
			.append($("<span>", {"text" : "닫기"}))
		);
		// 메일 이벤트
		$("#employeeInfo" + mode +" .link").children("[data-icon=mail]").on("click", function() {
			employeeFavorites.sendMail(item.DisplayName, item.MailAddress);
		});
		// 이음톡 이벤트
		$("#employeeInfo" + mode +"  .link").children("[data-icon=chat]").on("click", function() {
			window.open(Common.getBaseConfig("eumWindowRegistry") + "open/chat?targetId=" + item.UserCode);
		});
		// 닫기 이벤트
		$("#employeeInfo" + mode +"  .close").on("click", function() {
			$("#employeeInfo" + mode).attr("hidden", "hidden");
		});
	}
}