/**
 * ctnLastDraft - [신규:컨텐츠] - 최근 결재 양식
 * Server Rendering.
 * @since 2023.3
 */
var lastDraftList = { 
	init: function (data, ext, caller, webPartID){
		lastDraftList.render(data, ext, caller, webPartID);
	},
	render: function(data, ext, caller, webPartID){
		
		let preId = "#"+webPartID;
		if(data && data[0] != null && data[0][0] != null && data[0][0].status && data[0][0].status == "SUCCESS"){
			
			var listData = data[0][0].list;
			var formHtml = "";
			var lang = Common.getSession("lang");
			
			if(listData.length > 0){

				if(caller == "Widget") {
					let $targetCntnsDiv = $(preId).find(".swiper");
					
	//				var swiperWrapper = "often_form";
//					$targetCntnsDiv.append($("<div>", {"class" : "swiper " + swiperWrapper +"_swiper swiper-container-horizontal"}));
					
					//var $targetCntnsSwiper = $targetCntnsDiv.find(".swiper-wrapper");
					$.each(listData, function(idx, item){
						if(idx > 9) return false;
						
						var classIdx = (idx%3)+1;
						
						var a_link = $("<a href='#' class='form_link c"+ (classIdx) +"'></a>");
						a_link.bind("click", function(){
							lastDraftList.clickPopup(item.FormID, item.FormPrefix);
						});
						a_link.append("<span>"+ CFN_GetDicInfo(item.LabelText, lang) +"</span>");
						
						$targetCntnsDiv.append($("<div>", {"class" : "swiper-slide"}).append(a_link));

					});
					
					/*$targetCntnsSwiper.after($("<div>", {"class" : "swiper-control"})
							.append($("<div>", {"class" : "swiper-button-prev often_form_button_prev"})
							.append($("<span>", {"value" : "Prev"}))
						)
							.append($("<div>", {"class" : "swiper-button-next often_form_button_next" })
							.append($("<span>", {"value" : "Next"}))
						)
					);

					
					new Swiper(".often_form_swiper", {
				        threshold: 5,
				        slidesPerView: 3,
				        slidesPerGroup: 3,
				        navigation: {
				            nextEl: ".often_form_button_next",
				            prevEl: ".often_form_button_prev",
				        }
			    	});*/
				}else if(caller == "Contents"){
					// y scrol
					let $targetCntnsDiv = $(preId);
					
					$(".widget_content", $targetCntnsDiv).empty();
					$(".widget_content", $targetCntnsDiv).append("<div data-custom-scrollbar><div class='form_list'></div></div>");
					$.each(listData, function(idx, item){
						if(idx > 4) return false;
						var a_link = $("<a href='#' class='form_link c"+ (idx%3+1) +"'></a>");
						a_link.bind("click", function(){
							lastDraftList.clickPopup(item.FormID, item.FormPrefix);
						});
						a_link.append("<span>"+ CFN_GetDicInfo(item.LabelText, lang) +"</span>");
	
						$(".form_list", $targetCntnsDiv).append(a_link);
					});
				}
			}else{
				// webpartDrawEmpty = function(item, className, message, registUrl)
				coviUtil.webpartDrawEmpty([], caller, webPartID, Common.getDic("msg_NoDataList"));
			}
		}else{
			coviUtil.webpartDrawEmpty([], caller, webPartID, Common.getDic("msg_NoDataList"));
			// coviCmn.traceLog("webpart" + webPartID + " Data fetch Error.");
		}
	},
	clickPopup: function(FormID, FormPrefix){
		var width = "790";
		
		if(IsWideOpenFormCheck(FormPrefix)){
			width = "1070";
		}else{
			width = "790";
		}
		CFN_OpenWindow("/approval/approval_Form.do?formID=" + FormID + "&mode=DRAFT", "", width, (window.screen.height - 100), "resize", "false");
	}
}