var employeeNotice = {
	// 임직원 소식 팝업 오픈
	goMoreList: function(){			
		var sTitle = Common.getDic("lbl_Employees") +" "+ Common.getDic("lbl_news");
		var sURL = "/groupware/portal/goEmployeesNoticeListPopup.do"
		
		Common.open("","EmployeesList",	sTitle,sURL.replace("{0}", Common.getBaseConfig("WebpartEmp")),"865px","700px","iframe",true,null,null,true);
	},
	// 셀렉트 박스 옵션 셋팅
	setSelectBox: function() {
		$("#employeeClass").append($("<option>", {"value" : "ALL", "text" : Common.getDic("lbl_all")}));
		
		$.each(Common.getBaseCode("EmployeesNotice").CacheData,function(i, item){
			$("#employeeClass").append($("<option>", {"value" : item.Code, "text" : CFN_GetDicInfo(item.MultiCodeName)}));
		});
	},
	// 임직원 소식 유형에 대한 처리를 하는 메서드
	getClassKind: function(type){
		var oType = new Object();
			
			switch(type){
				case 'Birth': //생일
					oType["Code"] = "Birth";
					oType["Class"] ="birthday";
					oType["Name"] = "<spring:message code='Cache.lbl_Birthday'/>";
					break;
				case 'Enter'://신규 입사
					oType["Code"] = "NewJoin";
					oType["Class"] ="new";
					oType["Name"] = "<spring:message code='Cache.lbl_New_Recruit'/>";
					break;
				default:
					var eventType = Common.getBaseCode("eventType");
					var vacationType = Common.getBaseCode("VACATION_TYPE");
		
					var flag = true;
					
					oType["Code"] = "Etc";
					oType["Class"] ="new";
					oType["Name"] = Common.getDic("VACATION_OTHER");

					$.each(eventType.CacheData, function(idx, item) {
						if(type.toLowerCase() == item.Code.toLowerCase()) {
							oType["Code"] = "Condolence";
							oType["Name"] = CFN_GetDicInfo(item.MultiCodeName);
							
							switch(item.Code) {
								case "marry":
									oType["Class"] ="marriage";
									break;
								case "promotion":
									oType["Class"] ="up";
									break;
								case "condolence":
									oType["Class"] ="flower";
									break;
								case "firstBirthDay":
									oType["Class"] ="first_birthday";
									break;
								default:
									oType["Class"] ="new";
									break;
							}
							
							flag = false;
							
							return;
						}
					});
					
					if(flag) {
						$.each(vacationType.CacheData, function(idx, item) {
							if(type == item.Code) {
								oType["Code"] = "Vacation";
								oType["Class"] ="holidays";
								oType["Name"] = CFN_GetDicInfo(item.MultiCodeName);
								return;
							}
						});
					}
					
					break;
			}
			
			return oType;
	},
	// 셀렉트 박스 값에 따라 조회 데이터를 그려주는 메서드
	loadNotice: function(data, status, webpartID) {
		var strTarget =  "#" +webpartID + " .widget_content .swiper"; //coviUtil.webpartSwiper("#contents_employee_notice", 3, 5000, -1,"N","");
		var $targetDiv = $(strTarget);
		
		if (coviUtil.isMobile()){   // PC버전일 경우
			$("#"+webpartID+ " #ctn_employee_notices_empty").removeClass("widget_empty").addClass("ui_empty");
		}
		
		$.each(data, function(i, item) {
			var typeObject = employeeNotice.getClassKind(item.Type);
			
			if((status == "ALL" || status == typeObject["Code"]) && employeeNotice.checkBaseCode(typeObject["Code"]))  {
				$targetDiv.append($("<div>", {"class" : "swiper-slide",  "data-status" : typeObject["Code"]})
							.append($("<div>", {"class" : "employee_card"})
								.append($("<em>", {"class" : typeObject["Class"]})
									.append($("<span>", {"text" : typeObject["Name"]}))
								)
								.append($("<div>", {"class" : "ui_avatar"})
									.append($("<img>", {
										"src" : !coviUtil.isMobile() ? coviCmn.loadImage(item.PhotoPath) : mobile_comm_getimg(item.PhotoPath), 
										"onerror": !coviUtil.isMobile() ? "coviCmn.imgError(this, true)" : "mobile_comm_imageerror(this, true)"})
									)
								)
								.append($("<strong>", {"text" : item.UserName}))
								.append($("<time>", {"text" : item.Date}))
								.append($("<ul>", {"class" : "flowerMenuList", "style":"display:none;left:auto;"})
									.append($("<li>", {"class" : "flowerProfile"})
										.append($("<a>", {"onclick":"javascript:coviCtrl.goProfilePopup(\'" + item.UserCode + "\');return false;", "text":Common.getDic("lbl_UserProfile")}))
									)
									.append($("<li>", {"class" : "flowerAddr"})
										.append($("<a>", {"onclick":"javascript:coviCtrl.addFavoriteContact(\'" + item.UserCode + "\');return false;", "text":Common.getDic("lbl_AddContact")}))
									)
								)
							)
						);
			}
		});
		
		if(!coviUtil.isMobile()) {
			$("#" + webpartID).on("click", function(e) {
				var $card = $(e.target).closest(".employee_card");
	
				if($card.length > 0) {
					if($card.find(".flowerMenuList").is(":visible")){
						$card.find(".flowerMenuList").hide();
					} else {
						$(this).find(".flowerMenuList").hide();
						$card.find(".flowerMenuList").show();
					}
				} else {
					$(this).find(".flowerMenuList").hide();
				}
			});
		}
		
		if($targetDiv.children().length == 0) {
			$("#" + webpartID + " .widget_card").children(".widget_content").hide();
			$("#" + webpartID + " #ctn_employee_notices_empty").show();
		}
		
		return;
	},
	// 셀렉트 값에 따라 필터링
	filter: function(status, webpartID) {
		var $list = $("#" + webpartID + " .widget_card .widget_content .swiper-slide");
		var cnt = 0;
		
		$.each($list, function(idx, item) {
			if(status != "ALL" && $(item).data("status") != status) $(item).hide();
			else {
				cnt++;
				$(item).show();
			}
		});
		
		if(cnt == 0) {
			$("#" + webpartID + " .widget_card").children(".widget_content").hide();
			$("#" + webpartID + " #ctn_employee_notices_empty").show();
		} else {
			$("#" + webpartID + " .widget_card").children(".widget_content").show();
			$("#" + webpartID + " #ctn_employee_notices_empty").hide();
		}
	},
	// baseCode 값에 셀렉트 구분 값 확인 여부
	checkBaseCode: function(type) {
		
		var flag = false;

		$.each(Common.getBaseCode("EmployeesNotice").CacheData,function(i, item){
			if(type == item.Code) {
				flag = true;
				return
			}
		});
		
		return flag;
	},
	// 시작 메서드
	init: function(data, ext, caller, webpartID) {
		
		const sessionObj = Common.getSession();
		
		if(sessionObj["isAdmin"] === "Y" || sessionObj["isEasyAdmin"] === "Y") {
			employeeNotice.adminSetting(data[0], webpartID, caller, ext.codolenceFolderKey);
		}
		
		employeeNotice.setSelectBox();

		$("#"+webpartID).children(".widget_card").find('.widget_more').on("click", function(e) {
			employeeNotice.goMoreList();
		});

		employeeNotice.loadNotice(data[0], "ALL", webpartID);
		
		$("#employeeClass").change("on", function() {
			employeeNotice.filter($("#employeeClass option:selected").val(), webpartID);
			
			new Swiper("#"+webpartID + "_swiper", {
		        threshold: !coviUtil.isMobile() ? 4 : 2,
		        slidesPerView: !coviUtil.isMobile() ? 4 : 2,
			    slidesPerGroup: !coviUtil.isMobile() ? 4 : 2,
		        navigation: {
		            nextEl: "."+webpartID + "_swiper_next",
		            prevEl: "."+webpartID + "_swiper_prev",
		        }
			});
		});
	},
	adminSetting : function(data, webpartID, caller, settingKey) {
		$("#" + webpartID + " .widget_option").append(
			$("<button>", {"type":"button", "data-action":"setting"}).append($("<span>", {"text" : Common.getDic("btn_Setting")}))
		);
		
		$("#" + webpartID + " .widget_option [data-action='setting']").on("click", function() {
			$("#" + webpartID + " .layer_divpop").attr("hidden", false);
		});
		
		$("#" + webpartID + " .layer_divpop .divpop_close, " + "#" + webpartID + " .layer_divpop #close_popup").on("click", function() {
			$("#" + webpartID + " .layer_divpop").attr("hidden", true);
		});
		
		$("#" + webpartID + " #condolenceFolderID").text(Common.getBaseConfig(settingKey));
		
		$("#" + webpartID + " #saveCondolenceFolderID").on("click", function() {
			var params = {
				"settingKey":settingKey, "settingVal":$("#" + webpartID + " #newCondolenceFolderID").val()
			};
			
			$.ajax({
				type:"POST",
				contentType: "application/json",
				url:"/groupware/portal/updateSettingKey.do",
				data:JSON.stringify(params),
				async:false,
				success: function(res) {
					coviCmn.reloadCache("BASECONFIG", sessionObj.DN_ID);
				}
			});
		});
	}
}