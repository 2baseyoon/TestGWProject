/* 프로그램 저작권 정보
//이 프로그램에 대한 저작권을 포함한 지적재산권은 (주)코비젼에 있으며,
//(주)코비젼이 명시적으로 허용하지 않은 사용, 복사, 변경, 제3자에의 공개, 배포는 엄격히 금지되며,
//(주)코비젼의 지적재산권 침해에 해당됩니다.
//(Copyright ⓒ 2011 Covision Co., Ltd. All Rights Reserved)
//
//You are strictly prohibited to copy, disclose, distribute, modify, or use  this program in part or
//as a whole without the prior written consent of Covision Co., Ltd. Covision Co., Ltd.,
//owns the intellectual property rights in and to this program.
//(Copyright ⓒ 2011 Covision Co., Ltd. All Rights Reserved)

///<creator>기술연구소</creator> 
///<createDate>2017.06.19</createDate> 
///<lastModifyDate></lastModifyDate> 
///<version>0.8.0</version>
///<summary> 
///공통 컨트롤
///</summary>
///<ModifySpc>
/// 
///</ModifySpc>
*/

if (!window.coviCtrl) {
    window.coviCtrl = {};
}

$(document).ready(function(){
 	$(document).click(function(e){ //문서 body를 클릭했을때 팝업종료
 		// 내 정보, 사이트링크, 사용자 정보 플라워 메뉴, 통합 알림 팝업
 		 if (!($("#myInfoViewList").has(e.target).length > 0 || $("#siteMapCont").has(e.target).length > 0  || $(".flowerMenuList").has(e.target).length > 0
 				 	|| $("#integratedAlarmCont").has(e.target).length > 0)) {
             if ($('.btnSiteMap').has(e.target).length > 0 || $('.btnSiteMap').is(e.target)) {
     			$('.myInfo').removeClass('active');
     			$('.flowerMenuList ').removeClass('active');
     			$("li[data-menu-id=Integrated]").removeClass('active');
                 return false;
             } else if ($('.myInfoViewBtn').has(e.target).length > 0 || $('.myInfoViewBtn').is(e.target)) {
     			$('.btnGnbView').removeClass('active');
     			$('.flowerMenuList ').removeClass('active');
     			$("li[data-menu-id=Integrated]").removeClass('active');
                 return false;
             } else if ($('.btnFlowerName').has(e.target).length > 0 || $('.btnFlowerName').is(e.target)) {
            	$('.myInfo').removeClass('active');
     			$('.btnGnbView').removeClass('active');
     			$("li[data-menu-id=Integrated]").removeClass('active');
                 return false;
             } else if ($("li[data-menu-id=Integrated]").has(e.target).length > 0 || $("li[data-menu-id=Integrated]").is(e.target)) {
            	$('.myInfo').removeClass('active');
      			$('.btnGnbView').removeClass('active');
      			$('.flowerMenuList ').removeClass('active');
             } else {
     			 $('.myInfo').removeClass('active');
            	 $('.btnGnbView').removeClass('active');
            	 $('.flowerMenuList ').removeClass('active');
            	 $("li[data-menu-id=Integrated]").removeClass('active');
            	 
      				/*2019.04 메일 좌우분할 시 너비 조정
      				console.log(":"+btnTopMenu)
      				try{
      					if((btnTopMenu) && CFN_GetQueryString("CLSYS") == "mail" && CFN_GetQueryString("CLMD") == "user" && CFN_GetQueryString("CLBIZ") == "Mail" ){
      						if($("#divJspMailLeftRightList").css("display") != "none"){
      							setTimeout(function(){
	          						ResizeWidthMailLeftRightList(OnOff);
      							}, 1000); 	      							
      						}
      						btnTopMenu = false;
      					}
      				}catch(e){
      					coviCmn.traceLog("btnTopMenu :"+e);
					} */                   	 
             }
         }		
  	});
});

(function(window) {
	var coviCtrl = {
			variables : {
				lang : "ko"
			},
			dictionary : {
				confirm : '확인;Check;确认;确认;;;;;;;;;;',
				cancel : '취소;Cancel;キャンセル;取消;;;;;;;;;;',
				msg_outOfTab : '이 탭을 벗어나시겠습니까?;Are you sure you want to exit this tab?;このタブを脱しますか;确定要离开这个标签吗?;;;;;',
				msg_checkDate : '시작일 보다 이전 일 수 없습니다.;Can not be prior to the start date.;開始日より以前生じる恐れがありません;不能比起开始往前走;;;;;',
				select : '선택;select;選択;选择;;;;;;;;',
				hour : '시간;hour;時;时;;;;;;;;',
				week : '주;Week;週;周;;;;;;',
				month : '달;Month;月;月;;;;;;;',
				year : '년;year;年;年;;;;;;;'
			},
			toggleSimpleMake : function(){				
				if($('.simpleMakeLayerPopUp').hasClass('active')){
					$('.simpleMakeLayerPopUp').removeClass('active');
				} else {
					$('.simpleMakeLayerPopUp').addClass('active');
					setSimpleMake();
					coviInput.setDate();
				}
			},
			bindmScrollV : function(target, option){
				var _option = {
					mouseWheelPixels : 50,
					scrollInertia: 350
				}; 
				
				_option = $.extend(_option, (typeof option == 'object') ? option : {});
				
				$.mCustomScrollbar.defaults.scrollButtons.enable=true; //enable scrolling buttons by default
					
				target.mCustomScrollbar(_option);
			},
			bindmScrollH : function(target){
				target.mCustomScrollbar({
					axis:"x",
					advanced:{autoExpandHorizontalScroll:true}
				});
			},
			bindmScrollVH : function(target){
				target.mCustomScrollbar({
					axis:"yx"
				});
			},
			renderImageViewer : function(target, option){
				var _option = {
					maxWidth : "400",
					maxHeight : "400",
					src : ""
				};   
				
				if(option != null){
					if(option.maxWidth != null && option.maxWidth != undefined && option.maxWidth != ''){
						_option.maxWidth = option.maxWidth;
					}
					if(option.maxHeight != null && option.maxHeight != undefined && option.maxHeight != ''){
						_option.maxHeight = option.maxHeight;
					}
					if(option.src != null && option.src != undefined && option.src != ''){
						_option.src = decodeURI(option.src);
					}
				}

				var width, height;
				var img = new Image();
				img.src = _option.src;
				img.onerror = coviCmn.imgError(img);
				img.onload = function(){
					var ratio = 0;
					if(this.width > this.height) {
			            // Check if the current width is larger than the max
			            if(this.width > _option.maxWidth){
			                ratio = _option.maxWidth / this.width;
			                width = _option.maxWidth;
			                height = parseInt(this.height * ratio);
			            }
			        } else {
			            // Check if current height is larger than max
			            if(this.height > _option.maxHeight){
			                ratio = _option.maxHeight / this.height;
			                height = _option.maxHeight;
			                width = parseInt(this.width * ratio);
			            }
			        }
					
					// 댓글 이미지 썸네일 클릭시 오류(기존오류)
					//$('#' + target).html('<img src="' + Common.getBaseConfig("ImageLoadURL") + encodeURIComponent(_option.src) + '" width="' + width + '" height="' + height + '" alt="Image" onerror="coviCmn.imgError(this);">');
					$('#' + target).html('<img src="' + _option.src + '" width="' + width + '" height="' + height + '" alt="Image" onerror="coviCmn.imgError(this);">');
				}
			},
			mapVariables : {
				lat : "37.5618315",
				lng : "126.8381855",
				clientId : "FQhRZe_TNsNBETy57gCA",
				url : "java.no1.com",
				imageSrc : ""
			},
			renderMap : function(target, option){
				$.getScript("https://openapi.map.naver.com/openapi/v3/maps.js?clientId=" + coviCtrl.mapVariables.clientId + "&submodules=geocoder")
				.done(function(script, textStatus) { 
					/*
					 * option = {
					 * 	lang : "ko",
					 * 	mapWidth : "",
					 * 	mapHeight : "",
					 * 	imgWidth : "",
					 * 	imgHeight : "",
					 * 	callback : ""
					 * 
					 * }
					 * */
					var _option = {
						lang : "ko",
						mapWidth : "400",
						mapHeight : "300",
						imgWidth : "100",
						imgHeight : "100",
						elemID : ""
					};
					
					if(option != null && option != undefined){
						if(option.mapWidth != null && option.mapWidth != undefined && option.mapWidth != ''){
							_option.mapWidth = option.mapWidth;
						}
						if(option.mapHeight != null && option.mapHeight != undefined && option.mapHeight != ''){
							_option.mapHeight = option.mapHeight;
						}
						if(option.imgWidth != null && option.imgWidth != undefined && option.imgWidth != ''){
							_option.imgWidth = option.imgWidth;
						}
						if(option.imgHeight != null && option.imgHeight != undefined && option.imgHeight != ''){
							_option.imgHeight = option.imgHeight;
						}
						if(option.elemID != null && option.elemID != undefined && option.elemID != ''){
							_option.elemID = option.elemID;
						}
					}
					
					//set locale
					var sessionLang = Common.getSession("lang");
					if(typeof sessionLang != "undefined" && sessionLang != ""){
						_option.lang = sessionLang;
					}
					
					coviCtrl.mapVariables.imageSrc = "";
					
					var html = '';
					html += '<div id="mapContainer" style="width: ' + _option.mapWidth + 'px; height: ' + _option.mapHeight + 'px; margin:15px auto; overflow: hidden;"></div>';
					html += '<br/>';
					html += '<div style="text-align:center;">';
					html += '	<button type="button" id="mapConfirmBtn" class="AXButton Classic">' + CFN_GetDicInfo(coviCtrl.dictionary.confirm, _option.lang) + '</button>';
					html += '	<button type="button" id="mapCancelBtn" class="AXButton Classic">' + CFN_GetDicInfo(coviCtrl.dictionary.cancel, _option.lang) + '</button>';
					html += '</div>';
					
					$('#' + target).html(html);
					//script 로드 후 타이밍 문제로 setInterval 사용
					var checkExist = setInterval(function() {
						   if (typeof naver.maps !== 'undefined') {
						      clearInterval(checkExist);
						      
						      var mapDiv = document.getElementById('mapContainer');

								//옵션 없이 지도 객체를 생성하면 서울시청을 중심으로 하는 11레벨의 지도가 생성됩니다.
								var position = new naver.maps.LatLng(parseFloat(coviCtrl.mapVariables.lat), parseFloat(coviCtrl.mapVariables.lng));
								var map = new naver.maps.Map(mapDiv, {
								    center: position,
								    zoom: 10
								});
								var marker = new naver.maps.Marker({
									position: position,
								    map: map
								});
								
								naver.maps.Event.addListener(map, 'click', function(e) {
								    marker.setPosition(e.coord);
								    coviCtrl.mapVariables.lat = e.coord.y.toString();
								    coviCtrl.mapVariables.lng = e.coord.x.toString();
								});
								
								$('#mapConfirmBtn').on('click', function(){
									
									var imgSrc = coviCtrl.geocode2Img(coviCtrl.mapVariables.lng, coviCtrl.mapVariables.lat, _option.imgWidth, _option.imgHeight);
									coviCtrl.mapVariables.imageSrc = imgSrc;
									
									//callback method 호출
									
									if(option.callback != null && option.callback != ''){
										if(window[option.callback] != undefined){
											window[option.callback](imgSrc, option.elemID);
										} else if(parent[option.callback] != undefined){
											parent[option.callback](imgSrc, option.elemID);
										} else if(opener[option.callback] != undefined){
											opener[option.callback](imgSrc, option.elemID);
										}
									}
								});
								
								$("#mapCancelBtn").on("click",function(){ 
									Common.Close(); 
								});
						   }
						}, 100); 
				})
				.fail(function(jqxhr, settings, exception) { 
					coviCmn.traceLog(exception);
				}); 
			},
			geocode2Img : function(lng, lat, width, height){
				var imgSrc = '';
				imgSrc += 'https://openapi.naver.com/v1/map/staticmap.bin?';
				imgSrc += 'clientId=' + coviCtrl.mapVariables.clientId + '&';
				imgSrc += 'url=' + coviCtrl.mapVariables.url + '&';
				imgSrc += 'crs=EPSG:4326&';
				imgSrc += 'center=' + lng + ',' + lat + '&';
				imgSrc += 'level=10&';
				imgSrc += 'w=' + width + '&';
				imgSrc += 'h=' + height + '&';
				imgSrc += 'baselayer=default&';
				imgSrc += 'markers=' + lng + ',' + lat;
				
				return imgSrc;
			},
			geocode2Addr : function(){ 
				// 좌표 -> 주소
				/*
				 * 	GET https://openapi.naver.com/v1/map/reversegeocode?encoding=utf-8&coordType=latlng&query=127.1052133,37.3595316
					Host: openapi.naver.com
					User-Agent: curl/7.43.0
					Accept: 
					Content-Type: application/json
					X-Naver-Client-Id: {애플리케이션 등록 시 발급받은 client id 값}
					X-Naver-Client-Secret: {애플리케이션 등록 시 발급받은 secret값}
				 * 
				 * */
				
			},
			addr2Geocode : function(addr, callback){
				// 주소 -> 좌표
				/*
				 * 	GET https://openapi.naver.com/v1/map/geocode?encoding=utf-8&coordType=latlng&query=%EB%B6%88%EC%A0%95%EB%A1%9C%206
					Host: openapi.naver.com
					User-Agent: curl/7.43.0
					Accept: 
					Content-Type: application/json
					X-Naver-Client-Id: {애플리케이션 등록 시 발급받은 client id 값}
					X-Naver-Client-Secret: {애플리케이션 등록 시 발급받은 secret값}
				 * */
				$.getScript("https://openapi.map.naver.com/openapi/v3/maps.js?clientId=" + coviCtrl.mapVariables.clientId + "&submodules=geocoder")
				.done(function(script, textStatus) { 
					
					var checkExist = setInterval(function() {
						   if (typeof naver.maps !== 'undefined') {
						      clearInterval(checkExist);
						      
						      naver.maps.Service.geocode({
							        address: addr
							    }, function(status, response) {
							        if (status !== naver.maps.Service.Status.OK) {
							        	items = null;
							        }else{
							        	var result = response.result, // 검색 결과의 컨테이너
							            items = result.items; // 검색 결과의 배열
							        }
							        
							        //callback method 호출
									if(callback != null && callback != ''){
										if(window[callback] != undefined){
											window[callback](items);
										} else if(parent[callback] != undefined){
											parent[callback](items);
										} else if(opener[callback] != undefined){
											opener[callback](items);
										}
									}
							        
							    });
						   }
						}, 100); 
				})
				.fail(function(jqxhr, settings, exception) { 
					coviCmn.traceLog(exception);
				}); 
			},
			addrVariables : {
				currentPage : 0,
				totalCount : 0,
				searchKey : ""
				
			},
			renderAddr : function(target, option){
				//변수 초기화
				coviCtrl.addrVariables.currentPage = 0;
				coviCtrl.addrVariables.totalCount = 0;
				coviCtrl.addrVariables.searchKey = "";
				
				var html = '';
				html += '<h3>주소 검색</h3>';
				html += '<div>';
				html += '	<input type="text" id="addrSearchTxt" placeholder="Search"/>';
				html += '	<button type="button" id="addrSearchBtn" class="AXButton Classic">검색</button>';
				html += '</div>';
				html += '<br/><br/>';
				html += '<h3>주소 목록</h3>';
				html += '<div id="addrList"></div>';
				html += '<br/><br/>';
				html += '<button type="button" id="addrPrevBtn" class="AXButton Classic">이전</button>';
				html += '<button type="button" id="addrNextBtn" class="AXButton Classic">다음</button>';
				
				$('#' + target).html(html);
				
				$('#addrSearchBtn').on('click', function(){
					var text;
					text = $('#addrSearchTxt').val();
					coviCtrl.addrVariables.searchKey = text;
					coviCtrl.getAddrApi("1", "10", text);
				});
				
				$('#addrPrevBtn').on('click', function(){
					if(coviCtrl.addrVariables.currentPage > 0){
						coviCtrl.getAddrApi(coviCtrl.addrVariables.currentPage - 1, "10", coviCtrl.addrVariables.searchKey);	
					}
				});
				
				$('#addrNextBtn').on('click', function(){
					if(coviCtrl.addrVariables.currentPage < coviCtrl.addrVariables.totalCount){
						coviCtrl.getAddrApi(coviCtrl.addrVariables.currentPage + 1, "10", coviCtrl.addrVariables.searchKey);	
					}
				});
			},
			getAddrRows : function(data){
				var html = '';
				var jusoData = data.results.juso;
				for (var i = 0; i < jusoData.length; i++) {
					html += '<div><span>우편번호 : ' + jusoData[i].zipNo + '</span>, <span>지번 : ' + jusoData[i].jibunAddr + '</span></div>';
				}
				return html;
			},
			getAddrApi : function(pCurrPage, pCountPerPage, pKeyword){
				$.ajax({
					url : "/covicore/control/getAddrAPI.do",
					type : "post",
					data : {
						currentPage : pCurrPage,
						countPerPage : pCountPerPage,
						keyword : pKeyword
					},
					dataType : "json",
					success : function(res){
						var jsonStr = res.list;
						var errCode = jsonStr.results.common.errorCode;
						var errDesc = jsonStr.results.common.errorMessage;
						
						if(errCode!= "0"){
							alert(errCode + " = " + errDesc);
						} else {
							if(jsonStr != ""){
								coviCtrl.addrVariables.currentPage = Number(jsonStr.results.common.currentPage);
								coviCtrl.addrVariables.totalCount = Number(jsonStr.results.common.totalCount);
								
								$('#addrList').html(coviCtrl.getAddrRows(jsonStr));
																
							}
						}
					 },
					 error: function(xhr,status, error){
						 coviCmn.traceLog(error);
					 }
				});
				
			},
			//2018.05.29 추가
			setMailOrgAutoTags : function(target, orgData){
				var itemObj = JSON.parse(orgData);
				var items = itemObj.item;
				var lang = Common.getSession("lang");
				//중복데이터 삽입 방지
				//비슷한 메일 주소일시 삽입이 안되는 오류 수정. ex aaa.covision.co.kr 입력후 aa.covision.co.kr
				var arrMail = [];
				$("#"+target).parent().children(".ui-autocomplete-multiselect-item").each(function(ind,itm){
					arrMail.push(JSON.parse($(itm).attr("data-json")).MailAddress.toLowerCase());
				});
				var itemMailAddress = items[0].MailAddress.toLowerCase();
				if((itemMailAddress != "" && (arrMail != null && arrMail.indexOf(itemMailAddress) == -1)) ||
						(items[0].Member && $("#"+target).parent().text().indexOf(items[0].DN.replace(';' , '')) == -1)){
					$.each(items, function(index, item) {
						var displayName = CFN_GetDicInfo(item.DN, lang); //.split(';')[0]; //TODO 다국어 처리 할 것   2020.06.29 kjkim2  다국어 처리
						if(displayName != item.UserCode && item.BizCardType != "GR"){
							displayName += "<"+item.UserCode+">";
						}
						
				var idx = $("#"+target).parent().children().length - 1;
				
					$("<div></div>")
		                .addClass("ui-autocomplete-multiselect-item")
		                //추가
		                .attr("id","divReceiver_" + target + idx)
		                .attr("data-json", JSON.stringify(item))
		                .attr("data-value", item.UserCode)
		                .attr("style", "cursor: pointer;")
		                .text(displayName)
		                .append(
		                        $("<input type=\"text\" autocomplete=\"off\"></input>")
		                        .addClass("ui-edit-input")
		                        .attr("id","txtReceiverEdit_" + target + idx)
		                        .attr("name","txtReceiverEdit")
		                        .attr("idx",index)
		                        .attr("receivertype",target)
		                        .attr("style", "display:none;")
		                        .attr("value", displayName)
		                        .attr("displayname",displayName)
		                )
		                .append(
		                    $("<span></span>")
		                        .addClass("ui-icon ui-icon-edit")
				                .attr("id","aReceiverEditBtn_" + target + idx)
		                        .click(function(){
		                        	var item = $(this).parent().parent();
									
		                            divReceiverMod_OnClick(idx, target, item);
		                        })
		                )
		                .append(
		                    $("<span></span>")
		                        .addClass("ui-icon ui-icon-close")
								.attr("id","aReceiverView_" + target + idx)
		                        .click(function(){
									$(".ui-autocomplete-multiselect-item").removeClass("ui-edit");		                            
									var item = $(this).parent();
		                            //delete self.selectedItems[item.text()]; //자동완성을 이용하여 추가한게 아니므로 삭제 하지 않아도 됨.
		                            item.remove();
		                        })
		                ).insertBefore($('#' + target ));
		                //.insertBefore(parent.$('#' + target ));
		                //.insertBefore($('#' + target ));
						//.insertBefore($('#' + target, parent.document));
					});
				} else{
					return;
				}
			},
			renderTags : function(target, data){
				/*
				 * data = [
				 * 	{
				 * 		url : '',
				 * 		text : ''
				 * 	},
				 * 	{}
				 * ]
				 * 
				 * */
				var html = '';
				html += '<div class="con_tags">';
				for (var i = 0; i < data.length; i++) {
					html += '<span class="span_tag"><a href="' + data[i].url + '">' + data[i].text + '</a></span>';
				}
				html += '</div>';
				$('#' + target).html(html);
			},
			getAutoTags : function(target){
				var result = [];
				var $conAutoTags = $('#' + target).parent();
				$conAutoTags.children('.ui-autocomplete-multiselect-item').each(function () {
					var tagObj = $.parseJSON($(this).attr('data-json'));
					tagObj.label = $(this).text();
					tagObj.value = $(this).attr('data-value');
				    result.push(tagObj);
				});
				return result;
			},
			setAutoTags : function(target, item){
				$("<div></div>")
                .addClass("ui-autocomplete-multiselect-item")
                .attr("data-json", JSON.stringify(item))
                .attr("data-value", item.value)
                .text(item.label)
                .append(
                    $("<span></span>")
                        .addClass("ui-icon ui-icon-close")
                        .click(function(a,b){
                            var item = $(this).parent();
                            $('#' + target).autocomplete( "removeItem", item );  //delete self.selectedItems[item.text()];
                            item.remove();
                        })
                ).insertBefore('#' + target);
				
				$('#' + target).autocomplete( "addItem", item );
			},
			setCustomAutoTags : function(target, source, option){
				$('#' + target).autocomplete({
					source : function(request, response){
						response($.map( source, function( item ) {
							var lbl = item[option.labelKey];
							var val = item[option.valueKey];
							
							if(lbl.indexOf(request.term) > -1){
								return {
				                	label: lbl,
				                    value: val
				                }	
							}
			            }));
					},
					autoFocus : option.autoFocus == null ? true : option.autoFocus,
					minLength : option.minLength,
					multiselect : option.multiselect,
					useEnter : option.useEnter,
					useDuplication : option.useDuplication,
					callBackFunction : option.callBackFunction
				});
			},
			setCustomAjaxAutoTags : function(target, url, option){
				$('#' + target).autocomplete({
					source : function(request, response){
						$.ajax({
							url : url,
							type : "post",
							data : {
								keyword : request.term
							},
							dataType : "json",
							success : function(res){
								response($.map( res.list, function( item ) {
									item["label"] = item[option.labelKey];
									item["value"] = item[option.valueKey];
										
									return item;
					            }));
							 },
							 error: function(xhr,status, error){
								 coviCmn.traceLog(error);
							 }
						});
					},
					autoFocus : option.autoFocus == null ? true : option.autoFocus,
					minLength : option.minLength,
					multiselect : option.multiselect,
					useEnter : option.useEnter,
					useDuplication : option.useDuplication,
					callType : option.callType,
					callBackFunction : option.callBackFunction
				});
				
				if(option.select != undefined){
					$('#' + target).autocomplete( "setSelect", option.select );
				}
			},
			// 동명이인 처리를 위해 부서명 표시 자동완성
			setUserWithDeptAutoTags : function(target, url, option){
				$('#' + target).autocomplete({
					source : function(request, response){
						$.ajax({
							url : url,
							type : "post",
							data : {
								keyword : request.term,
								haveDept : "Y"
							},
							dataType : "json",
							success : function(res){
								response($.map( res.list, function( item ) {
									if(item[option.addInfoKey] != undefined && item[option.addInfoKey] != ""){
										item["label"] = item[option.labelKey] + " [" + item[option.addInfoKey] + "]";
									}else{
										item["label"] = item[option.labelKey];
									}
									
									item["value"] = item[option.valueKey];
									item["saveLabel"] = item[option.labelKey];
									
									return item;
					            }));
							 },
							 error: function(xhr,status, error){
								 coviCmn.traceLog(error);
							 }
						});
					},
					autoFocus : option.autoFocus == null ? true : option.autoFocus,
					minLength : option.minLength,
					multiselect : option.multiselect,
					useEnter : option.useEnter,
					useDuplication : option.useDuplication,
					callType : option.callType
				});
				
				if(option.select != undefined){
					$('#' + target).autocomplete( "setSelect", option.select );
				}
			},
			// 메일주소로 사용자 자동완성
			setUserMailAddressWithDeptAutoTags : function(target, url, option){
				$('#' + target).autocomplete({
					source : function(request, response){
						$.ajax({
							url : url,
							type : "post",
							data : {
								keyword : request.term,								
								haveDept : "Y",
								searchMailAddress : "Y"
							},
							dataType : "json",
							success : function(res){
								response($.map( res.list, function( item ) {
									if(item[option.addInfoKey] != undefined && item[option.addInfoKey] != ""){
										item["label"] = item[option.labelKey] + " [" + item[option.addInfoKey] + "]";
									}else{
										item["label"] = item[option.labelKey];
									}
									
									item["value"] = item[option.valueKey];
									item["saveLabel"] = item[option.labelKey];
									
									return item;
					            }));
							 },
							 error: function(xhr,status, error){
								 coviCmn.traceLog(error);
							 }
						});
					},
					autoFocus : option.autoFocus == null ? true : option.autoFocus,
					minLength : option.minLength,
					multiselect : option.multiselect,
					useEnter : option.useEnter,
					useDuplication : option.useDuplication,
					callType : option.callType
				});
				
				if(option.select != undefined){
					$('#' + target).autocomplete( "setSelect", option.select );
				}
			},
			/*2018.06.08 연락처, 최근수신자, 그룹메일 조회용 파라미터 추가*/
			setCustomMailAjaxAutoTags : function(target, url, option){
				$('#' + target).autocomplete({
					source : function(request, response){
						//2자 이하일 경우
						/*
						if(request.term.length < 2){
							return;
						}
						*/
						
						$.ajax({
							url : url,
							type : "post",
							data : {
								keyword : request.term,
								userId : option.paramUserId,
								userMailId : option.paramUserMail,
								domainCode : option.paramDomainCode
							},
							dataType : "json",
							success : function(res){
								response($.map( res.list, function( item ) {
									
									item["label"] = item[option.labelKey];
									item["value"] = item[option.valueKey];
									item["nameKey"] = item[option.nameKey];
									
									return item;
					            }));
							 },
							 error: function(xhr,status, error){
								 coviCmn.traceLog(error);
							 }
						});
					},
					open: function() {
			            var mailAuto = $('.mailAutoSetting');
			            $('.ui-autocomplete').each(function(index, element){
			            	$(element).css("width", (element.offsetWidth + 30) + "px" );
			    			if($(element).css("display") !== "none" && (mailAuto.length > 0 && mailAuto.css('display') == 'none') ){
			    				mailAuto.show();
			    				mailAuto.css("top", (element.offsetTop + element.offsetHeight - 1) + "px");
			    				mailAuto.css("left", element.offsetLeft + "px");
			    				mailAuto.css("width", element.offsetWidth + "px");
			    				$(element).append(mailAuto);
			    			}
			    		})
			        },
			        search: function() {
			            var mailAuto = $('.mailAutoSetting');
		    			if( mailAuto.length > 0 && mailAuto.css('display') !== 'none' ){
		    				mailAuto.hide();
		    				$('div[name=divBccInput]').after(mailAuto);
		    			}
			        },
			        close: function() {
			            var mailAuto = $('.mailAutoSetting');
		    			if( mailAuto.length > 0 && mailAuto.css('display') !== 'none' ){
		    				mailAuto.hide();
		    				$('div[name=divBccInput]').after(mailAuto);
		    			}
			        },
			        autoFocus : option.autoFocus == null ? true : option.autoFocus,
					minLength : option.minLength,
					multiselect : option.multiselect,
					useEnter : option.useEnter,
					callType : option.callType
				});
				
				if(option.select != undefined){
					$('#' + target).autocomplete( "setSelect", option.select );
				}
			},
			setAddrAutoTags : function(target, option){
				$('#' + target).autocomplete({
					source : function(request, response){
						$.ajax({
							url : "/covicore/control/getAddrAPI.do",
							type : "post",
							data : {
								currentPage : 1,
								countPerPage : option.count,
								keyword : request.term
							},
							dataType : "json",
							success : function(res){
								var jsonStr = res.list;
								var errCode = jsonStr.results.common.errorCode;
								var errDesc = jsonStr.results.common.errorMessage;
								
								if(errCode!= "0"){
									coviCmn.traceLog("error at : coviCtrl.setAddrAutoTags : " + errCode + " = " + errDesc);
								} else {
									if(jsonStr != ""){
										var jusoData = jsonStr.results.juso;
										
										response($.map( jusoData, function( item ) {
											var lbl = item.jibunAddr;
											var val = item.zipNo;
												
											return {
														label: lbl,
														value: val
													};	
							            }));
									}
								}
							 },
							 error: function(xhr,status, error){
								 coviCmn.traceLog(error);
							 }
						});
					},
					autoFocus : option.autoFocus == null ? true : option.autoFocus,
					minLength : option.minLength,
					multiselect : option.multiselect,
					useEnter : option.useEnter,
					callBackFunction : option.callBackFunction
				});
			},
			getHashTags : function(target, hashChar){
				var result = [];
				var $conHashTags = $('#' + target).parent().prev();
				$conHashTags.children('span').each(function () {
				    if($(this).attr('data-hashchar') == hashChar){
				    	var txt = $(this).text();
				    	result.push(txt.substring(1, txt.length));
				    }
				});
				return result;
			},
			setHashTags : function(target, option){
				/*
				 * option : {
				 * 	allowedChar : ['_', '-'],
				 * 	hashChar : ['#', '@']
				 * }
				 * 
				 * */
				var opt = {
					allowedChar : ['_', '-'],
					hashChar : ['#']
				};
				
				if(option != null){
					opt = option;
				}
				
				var $this;
				if($.type(target) === 'string'){
					$this = $('#' + target);
				} else {
					$this = target;
				}
				
				var patternString = '(^|\\s)(';
				patternString += opt.hashChar.join("|");
				patternString += ')([a-zA-Z0-9가-힣ㄱ-ㅎㅏ-ㅣ\\d';
				patternString += opt.allowedChar.join("");
				patternString += ']+)';
				
				var regEx = new RegExp(patternString, "g");
				
				$this.wrap('<div class="jqueryHashtags"><div class="highlighter"></div></div>').unwrap().before('<div class="highlighter"></div>').wrap('<div class="typehead"></div></div>');
				$this.addClass("theSelector");
				autosize($this);
				$this.on("keyup", function() {
					var str = $(this).val();
					$(this).parent().parent().find(".highlighter").css("width",$(this).css("width"));
					//str = str.replace(/\n/g, '<br>');
					str = str.replace(regEx,'$1<span class="hashtag" data-hashchar="$2">$2$3</span>');
					
					$(this).parent().parent().find(".highlighter").html(str);
				});
				$this.parent().prev().on('click', function() {
					$this.parent().find(".theSelector").focus();
				});
				
			},
			bindHashTags : function(target, option){
				/*
				 * option : {
				 * 	allowedChar : ['_', '-'],
				 * 	hashChar : ['#', '@']
				 * }
				 * 
				 * */
				var opt = {
					allowedChar : ['_', '-'],
					hashChar : ['#']
				};
				
				if(option != null){
					opt = option;
				}
				
				var $this;
				if($.type(target) === 'string'){
					$this = $('#' + target);
				} else {
					$this = target;
				}
				
				var patternString = '(^|\\s)(';
				patternString += opt.hashChar.join("|");
				patternString += ')([a-zA-Z0-9가-힣ㄱ-ㅎㅏ-ㅣ\\d';
				patternString += opt.allowedChar.join("");
				patternString += ']+)';
				
				var regEx = new RegExp(patternString, "g");
				
				$this.wrap('<div class="jqueryHashtags"><div class="highlighter"></div></div>').unwrap().before('<div class="highlighter"></div>').wrap('<div class="typehead"></div></div>');
				$this.addClass("theSelector");
				autosize($this);
				$this.on("keyup", function() {
					var str = $(this).val();
					$(this).parent().parent().find(".highlighter").css("width",$(this).css("width"));
					//str = str.replace(/\n/g, '<br>');
					str = str.replace(regEx,'$1<span class="hashtag" data-hashchar="$2">$2$3</span>');
					
					$(this).parent().parent().find(".highlighter").html(str);
				});
				$this.parent().prev().on('click', function() {
					$this.parent().find(".theSelector").focus();
				});
				
			},
			renderLike : function(target, option, data){
				var html = '';
				
				/*
				 * option = {
				 * 	likeType : 'emoticon' or 'point',
				 * 	emoticon : ['thumbs', 'heart', 'smile', 'meh', 'frown'],
				 * 	point : 5,
				 *  callback : ''
				 * }
				 * 
				 * data = {
				 *  likeType : 'emoticon',
				 *  emoticon : 'thumbs',
				 *  count : 2
				 * }
				 * 
				 * data = {
				 *  likeType : 'point',
				 *  count : 2
				 * }
				 * 
				 * */
				if(option.likeType == 'emoticon'){
					
					if(option.emoticon != undefined && option.emoticon != null){
						if($.inArray('thumbs', option.emoticon) != -1){
							html += '<a href="javascript:;" onclick="coviCtrl.likeClick(this, \'' + option.likeType + '\', \'' + option.callback + '\')">';
							html += '<i class="fa fa-thumbs-o-up fa-2x" aria-hidden="true"></i>&nbsp;<span data-emoticon="thumbs">0</span>&nbsp;</a>';
						}
						if($.inArray('heart', option.emoticon) != -1){
							html += '<a href="javascript:;" onclick="coviCtrl.likeClick(this, \'' + option.likeType + '\', \'' + option.callback + '\')">';
							html += '<i class="fa fa-heart-o fa-2x" aria-hidden="true"></i>&nbsp;<span data-emoticon="heart">0</span>&nbsp;</a>';
						}
						if($.inArray('smile', option.emoticon) != -1){
							html += '<a href="javascript:;" onclick="coviCtrl.likeClick(this, \'' + option.likeType + '\', \'' + option.callback + '\')">';
							html += '<i class="fa fa-smile-o fa-2x" aria-hidden="true"></i>&nbsp;<span data-emoticon="smile">0</span>&nbsp;</a>';
						}
						if($.inArray('meh', option.emoticon) != -1){
							html += '<a href="javascript:;" onclick="coviCtrl.likeClick(this, \'' + option.likeType + '\', \'' + option.callback + '\')">';
							html += '<i class="fa fa-meh-o fa-2x" aria-hidden="true"></i>&nbsp;<span data-emoticon="meh">0</span>&nbsp;</a>';
						}
						if($.inArray('frown', option.emoticon) != -1){
							html += '<a href="javascript:;" onclick="coviCtrl.likeClick(this, \'' + option.likeType + '\', \'' + option.callback + '\')">';
							html += '<i class="fa fa-frown-o fa-2x" aria-hidden="true"></i>&nbsp;<span data-emoticon="frown">0</span>&nbsp;</a>';
						}
					}
					
					
				} //2. point
				else if(option.likeType == 'point'){
					if(option.point != undefined && option.point != null){
						html += '<p class="like_star_rating">';
						for (var i = 0; i < option.point; i++) {
							html += '<a href="javascript:;" class="on" onclick="coviCtrl.likeClick(this, \'' + option.likeType + '\', \'' + option.callback + '\')">★</a>';
						}
						html += '</p>';
					}
				}
				
				$('#' + target).html(html);
				if(data != null){//TODO event 처리 disabled 처리 할 것
					var $this;
					if(data.likeType == 'emoticon'){
						$this = $('#' + target).find('[data-emoticon="' + data.emoticon + '"]');
						$this.text(data.count);
					} else if(data.likeType == 'point'){
						$this = $('#' + target + ' .like_star_rating');
						$this.children("a").removeClass("on");
						$this.children("a").eq(Number(data.count)-1).addClass("on").prevAll("a").addClass("on");
					}
				}
				
			},
			likeClick : function(elem, likeType, callback){
				var $this = $(elem);
				var data, cnt;
				if(likeType == 'emoticon'){
					var $span = $this.find('span');
					cnt = Number($span.text()) + 1;
					var emoticon = $span.attr('data-emoticon');
					
					data = {'likeType' : likeType, 'emoticon' : emoticon, 'count' : cnt};
					$span.text(cnt);
				} else if(likeType == 'point'){
					$this.parent().children("a").removeClass("on");
					$this.addClass("on").prevAll("a").addClass("on");
					
					cnt = $this.parent().find('.on').length;
					data = {'likeType' : likeType, 'count' : cnt};
				}
				
				//callback method 호출
				if(callback != null && callback != ''){
					if(window[callback] != undefined){
						window[callback](data);
					} else if(parent[callback] != undefined){
						parent[callback](data);
					} else if(opener[callback] != undefined){
						opener[callback](data);
					}
				}
			},
			makeSelectData : function(codeList, initInfo, lang){
				lang = coviCmn.isNull(lang, "");
				
				var html = '';
				var defaultHtml = '';
				var hasGroupCode = coviCmn.isNull(initInfo.hasGroupCode, "Y");
				var width = coviCmn.isNull(initInfo.width, "");
				width = $.isNumeric(width) ? (width + "px") : width;

				html += '<select class="selectType04 ' + (initInfo.cls != undefined && initInfo.cls != "" ? initInfo.cls : "") +'" '+ (width != '' ? 'style="width:' + width + ';"' : '') + (initInfo.id != undefined && initInfo.id != '' ? 'id="' + initInfo.id + '"' : '') + (initInfo.name != undefined && initInfo.name != '' ? 'name="' + initInfo.name + '"' : '')+ '>';
				if(initInfo.hasAll){
					if(initInfo.hasAllText != undefined && initInfo.hasAllText != "") {
						html+= '<option value=\"\">'+ initInfo.hasAllText +"</option>";
					} else {
						html+= '<option value=\"\">'+ CFN_GetDicInfo("전체;All;すべて;所有;;;;;", (lang != "" ?  lang : "ko" ))+"</option>";
					}
				}

				for(var i = 0; i < codeList.length; i++) { 
					var codeObj = codeList[i];
					var codeName = (lang != "" ? CFN_GetDicInfo(codeObj.MultiCodeName, lang) : codeObj.CodeName);
					var reserved1 = codeObj.Reserved1;
					var reserved2 = codeObj.Reserved2;
					var reserved3 = codeObj.Reserved3;

					if(initInfo.codeGroup == codeObj.Code && hasGroupCode == "N"){
						continue;
					}
					
				    if(codeObj.Code == initInfo.defaultVal){
				    	html += '	<option selected ';
				    } else {
				    	html += '	<option ';
				    }
				    html += ' value= "' + codeObj.Code
						+ '" data-code="' + codeObj.Code
						+ '" data-codename="' + codeName
						+ '" data-reserved1="' + reserved1
						+ '" data-reserved2="' + reserved2
						+ '" data-reserved3="' + reserved3
						+ '">' + codeName + '</option>';
				}
				html += '</select>';
				return html;
			},
			
			renderNormalSelect : function(targetObj, url, postParams, options, lang){
				lang = coviCmn.isNull(lang, "");
				
				var html = '';
				var className = options.className || "selectType04";
				var width = coviCmn.isNull(options.width, "");
				width = $.isNumeric(width) ? (width + "px") : width;

				$.ajax({
					url : url
					, async : false
					, method : "POST"
					, data : postParams
					, success : function (data){
						var _list = data[options.listDataKey || "list"];
						html += '<select class="'+ className +'" '+ (width != '' ? 'style="width:' + width + ';"' : '') + '>';
						for(var i = 0; i < _list.length; i++) {
							var dataObj = _list[i];
							var _value = dataObj[options.valueKey];
							var _name = CFN_GetDicInfo(dataObj[options.nameKey]);
							
						    if(options.defaultVal && _value == options.defaultVal){
						    	html += '	<option selected ';
						    } else {
						    	html += '	<option ';
						    }
						    html += ' value= "' + _value
								+ '" data-code="' + _value
								+ '" data-codename="' + _name
								+ '">' + _name + '</option>';
						}
						html += '</select>';
						
						targetObj.html(html);
						if(options.onchange && (typeof options.onchange) == "function"){
							targetObj.change(function(){
								options.onchange.call(this, targetObj[0]);
							});
						}
					}
				});
			},
			/*
			makeSelectData : function(codeList, initInfo, lang){
			
				var width = initInfo.width;
				
				var html = '';
				var defaultHtml = '';
				html += '<div class="selBox" style="width:' + (Number(width)-15) + 'px;">';
				html += '	<!--defaultHtml-->';
				if(initInfo.height != "" && initInfo.height!=undefined)
					html += '	<div class="selList" style="width: ' + width + 'px;display:none;overflow-y:auto;max-height:'+initInfo.height+'px">';
				else
					html += '	<div class="selList" style="width: ' + width + 'px;display:none;">';
				
				for(var i = 0; i < codeList.length; i++) { 
				    var codeObj = codeList[i];
				    if(codeObj.Code == initInfo.defaultVal){
				    	defaultHtml += '	<span class="selTit"><a href="javascript:;" onclick="coviCtrl.clickDefault(this);" data-code="' + codeObj.Code + '" class="up"">' + codeObj.CodeName + '</a></span>';
				    }
					html += '		<a href="javascript:;" class="listTxt" data-code="' + codeObj.Code + '" onclick="coviCtrl.clickSelectListBox(this, \'' + initInfo.onclick + '\');" data-codename="' + codeObj.CodeName + '">' + codeObj.CodeName + '</a>';
		            
				}
				html += '	</div>';
				html += '</div>';
				return html.replace('<!--defaultHtml-->', defaultHtml);
			},
			clickDefault : function(elem){
				var $selList = $(elem).parent().parent().find('.selList');
				
				if($selList.css('display') == 'none'){
					$selList.show();
				}else{
					$selList.hide();
				}
			},
			clickSelectListBox : function(elem, onclickFnName){
				
				
				var $this = $(elem);
				var $selList = $this.parent();
				var $up = $selList.prev().children();	
				
				if($selList.css('display') == 'none'){
					$selList.show();
				}else{
					$selList.hide();
				}
				
				if($this.attr('class')=='listTxt' || $this.attr('class')=='listTxt select'){
					$selList.find(".listTxt").attr("class", "listTxt");
					$this.attr("class","listTxt select");
					$up.html($this.attr("data-codename"));
					$up.attr("data-code", $this.attr("data-code"));
				}
				
				//callback method 호출
				if(onclickFnName != null && onclickFnName != '' && onclickFnName !="undefined" && onclickFnName!=null){
					if(window[onclickFnName] != undefined){
						window[onclickFnName]();
					} else if(parent[onclickFnName] != undefined){
						parent[onclickFnName]();
					} else if(this[onclickFnName] != undefined){
						this[onclickFnName](elem);
					} else if(opener[onclickFnName] != undefined){
						opener[onclickFnName]();
					}
				}
			},*/
			/*
			 * initInfos : [
			 * 	{
			 * 		target : '',
			 * 		codeGroup : '',
			 * 		defaultVal : '',
			 * 		width : '',
			 * 		oncomplete : '',
			 * 		onclick : ''
			 * 	}
			 * 
			 * 
			 * ]
			 * 
			 * */
			makeCodeGroups : function(initInfos){
				var codeGroupArr = [];
				for(var i = 0; i < initInfos.length; i++) {
					var initInfoObj = initInfos[i];
					codeGroupArr.push(initInfoObj.codeGroup);
				}
				
				return codeGroupArr.join(",");
			},
			getInitInfo : function(codeGroup, initInfos){
				var retObj;
				for(var i = 0; i < initInfos.length; i++) {
					var initInfoObj = initInfos[i];
					if(initInfoObj.codeGroup == codeGroup){
						retObj = initInfoObj;
					}
				}
				
				return retObj;
			},
			getCodeList : function(codeGroup, dataList){
				var retObj;
				for(var i = 0; i < dataList.length; i++) {
					if(dataList[i].hasOwnProperty(codeGroup)){
						retObj = dataList[i];
					}
				}
				
				return (retObj == undefined ?  [] :  retObj[codeGroup]);
			},
			/*
			getSelected : function(target){
				var returnObj = new Object();
				var $target = $('#' + target).find('.selTit').children(); 
				
				returnObj.text = $target.html();
				returnObj.val = $target.attr('data-code');
				
				return returnObj; 
			},
			setSelected : function(target, val){
				var $selList = $('#' + target + ' .selList');
				var $up = $selList.prev().children();	
				
				$selList.children().each(function() {
					var $this = $(this);
					if($this.attr('data-code') == val){
						if($this.attr('class')=='listTxt' || $this.attr('class')=='listTxt select'){
							$selList.find(".listTxt").attr("class", "listTxt");
							$this.attr("class","listTxt select");
							$up.html($this.attr("data-codename"));
							$up.attr("data-code", $this.attr("data-code"));
						}	
					}
				});
			},*/
			getSelected : function(target){
				var returnObj = new Object();
				var $selected = $('#' + target + ' select option:selected');
				
				returnObj.text = $selected.text();
				returnObj.val = $selected.val();
				
				return returnObj; 
			},
			setSelected : function(target, val){
				$('#' + target + ' select').val(val);
			},
			/*renderSelect : function(initInfos, dataList, lang){
				var html;
				for(var i = 0; i < initInfos.length; i++) {
					var initInfoObj = initInfos[i];
					var codeGroup = initInfoObj.codeGroup;
					var oncompleteFnName = initInfoObj.oncomplete;
					var onclickFnName = initInfoObj.onclick;
					
					html = coviCtrl.makeSelectData(coviCtrl.getCodeList(codeGroup, dataList), initInfoObj, lang);
					$('#' + initInfoObj.target).html(html);
					
					if(onclickFnName != null && onclickFnName != '' && onclickFnName !="undefined" && onclickFnName!=null){
						$('#' + initInfoObj.target + " select").change(function(){
							//callback method 호출
							if(window[onclickFnName] != undefined){
								window[onclickFnName]();
							} else if(parent[onclickFnName] != undefined){
								parent[onclickFnName]();
							} else if(this[onclickFnName] != undefined){
								this[onclickFnName](elem);
							} else if(opener[onclickFnName] != undefined){
								opener[onclickFnName]();
							}
						});
					}
					
					//oncomplete
					if(oncompleteFnName != null && oncompleteFnName != ''){
						if(window[oncompleteFnName] != undefined){
							window[oncompleteFnName](this);
						} else if(parent[oncompleteFnName] != undefined){
							parent[oncompleteFnName](this);
						} else if(opener[oncompleteFnName] != undefined){
							opener[oncompleteFnName](this);
						}
					}
				}
			},*/
			/*
			* InitInfo = {
			* 	target : 공유 버튼이 그려질 위치
			* 	currentTarget : 현재 페이지가 어떤 페이지 인지 ((ex) 게시판인지, 일정인지)
			* 	shareTarget : 어떤 페이지로 공유를 할 것인지 ((ex) 게시판으로 공유, 일정으로 공유)

			* }
			* dataInfos = {
			* 	buttonText : 버튼 그려질 데이타
			* 	buttonIcon : 버튼에 그려질 아이콘
			* }
			*/

			renderShare : function(initInfos, dataInfos){/*
				var html = '<a onclick="coviCtrl.toggleShare();" class="btnContentShare">공유</a>';	*/
				var html = '<input type="button" onclick="coviCtrl.toggleShare()" value="공유">'
				$('#'+initInfos.target).html(html)
				
				var div_margin_left = $('[kind = share]').css('margin-left');
				var div_margin_right = '0px';
				var div_width = $('[kind = share]').css('width');
				var body_width=$('body').width;
				if(div_margin_left+div_width > body_width)
					div_margin_right='0px';
				
				html = '<div id="wrapper" style="display:none;border: 2px solid #48BAE4; z-index:8; position:absolute;width:300px;height:200px;padding:10px;margin-left:'+div_margin_left+';">';
				
				
				for(var i=0;i<dataInfos.length;i++){
					var shareType="";
					switch(initInfos.currentTarget){
						case 'board': 
							switch(dataInfos[i].shareTarget){
								//데스트를 위해서 데이터를 바꿉니다.
								case 'board': shareType = "A"; break;
								case 'social':shareType = "UI"; break;
								case 'schedule':shareType = "TCD"; break;
								case 'mail': shareType = "TUI"; break;
								case 'community': shareType = "A"; break;
							}
							break;
						case 'social':
							switch(dataInfos[i].shareTarget){
								case 'board': shareType = "TC"; break;
								case 'social':shareType = "A"; break;
								case 'schedule':shareType = "TCD"; break;
								case 'mail': shareType = "TUI"; break;
								case 'community': shareType = "TC"; break;
							}
							break;
						case 'schedule':
						case 'resource': 
							switch(dataInfos[i].shareTarget){
								case 'board': shareType = "TU"; break;
								case 'social':shareType = "U"; break;
								case 'schedule':shareType = "A"; break;
								case 'mail': shareType = "TU"; break;
								case 'community': shareType = "U"; break;
							}
							break;
						case 'survey': 
							switch(dataInfos[i].shareTarget){
								case 'board': shareType = "TU"; break;
								case 'social':shareType = "U"; break;
								case 'schedule':shareType = "TCD"; break;
								case 'mail': shareType = "TU"; break;
								case 'community': shareType = "U"; break;
							}
							break;
						case 'community': 
							switch(dataInfos[i].shareTarget){
								case 'board': shareType = "A"; break;
								case 'social':shareType = "UI"; break;
								case 'schedule':shareType = "TCD"; break;
								case 'mail': shareType = "TUI"; break;
								case 'community': shareType = "U"; break;
						}
					}  //시나리오 작성된 것을 바탕으로 어떤 곳에서 어떤 곳으로 공유하는지에 따라서 달라지는 값
					
					var url = dataInfos[i].url+"?";
					/*'A'://전부
					 * C':  //콘텐츠(내용)
					 * 'T':  //제목
					 * 'I':  //이미지 url
					 *  N':  //시간
					 * 'U': //단순 url
					 */
					url+="type="+shareType; //get방식으로 type, url전달하는 데이터
					html += "<button id="+initInfos.currentTarget+" name = "+initInfos.currentTarget+" onclick=coviCtrl.callSharePopup('"+(url)+"','"+dataInfos[i].buttonText+"')><i class='"+dataInfos[i].buttonIcon+"' aria-hidden='true'></i> "+dataInfos[i].buttonText+"</button>";
				}
				html += "<textarea name=imgData style='display:none;'></textarea>";
				
				/*html += "<input name=urlData id=urlData type=text style='width:280px'><button value=복사 data-clipboard-target='#urlData' id=copy onclick=coviCtrl.copyUrl()>";
				*/
				
				html+='<input type = "text" name="urlData" id = "urlData"><input type="button" name = copy value="복사" data-clipboard-target="[name=urlData]" onclick="coviCtrl.copyUrl()">'

				html += '</div>';
				$('#'+initInfos.target).append(html);
			},
			/*
				공유 버튼을 누를 때 마다 열리고 닫치는 기능을 구현.
				이미지 데이터와 url 데이터를 미리 세팅
			*/
			toggleShare : function(){  
				$('#wrapper').toggle();
				var targetElem = $('#Share');

				html2canvas(targetElem, {
					onrendered : function(canvas) {
						var imgData = canvas.toDataURL("image/png");
						$('[name=imgData]').val(imgData)
					}
				});
				var urlData = document.URL;
				$('[name=urlData]').val(urlData);
			},
			copyUrl : function(){
				var clipboard = new Clipboard('[name=copy]');
			},
			getSelectedShareData : function(){
				var json='{';
				var dataSection=['title', 'content', 'img', 'time', 'url'];
				
				for(var i=0;i<dataSection.length;i++){
					var str = $('#'+dataSection[i]).text();
					if(str != ""){
						json += '"'+dataSection[i]+'":"'+str+'",';
					}else{
						var str = $('#'+dataSection[i]).attr("src");
						if(str!=""){
							json += '"'+dataSection[i]+'":"'+str+'",';
						}
					}
				}
				json = json.substr(0, json.length-1);
				json +='}';
				return JSON.parse(json);
			},
			
			/*
			 * 구독버튼을 클릭했을 경우
			 */
			addSubscription : function( pTargetID ){  //pServiceType: Schedule, pTargetID: FolderID
				var targetServiceType = CFN_GetQueryString("CLBIZ");
				
				if(targetServiceType == "Schedule"){	//일정관리는 체크박스 형태이므로 별도 parameter 생성
					var targetIDs = '';
            		$(".subscriptionPopList input[type=checkbox]:checked").each(function(){
            			targetIDs += $(this).attr('value')+";";
            		});
            		
            		if(targetIDs.length > 0){
            			pTargetID = targetIDs.substring(0,targetIDs.length-1);
            		}
            	}
            	
            	if(pTargetID == undefined || pTargetID == ""){
            		Common.Warning(Common.getDic("msg_subscribeTarget"+targetServiceType));
            		return;
            	}
				
				Common.Confirm(Common.getDic("msg_RUSetSubscription"+targetServiceType), 'Confirmation Dialog', function (result) {
		            if (result) {
						
		            	$.ajax({
		        	    	type:"POST",
		        	    	url:"/covicore/subscription/addSubscription.do",
		        	    	data:{
		        	    		"targetServiceType": targetServiceType	//BizSection: Scheudle, Board, Doc, Community ...
		        	    		,"targetID": pTargetID
		        	    	},
		        	    	success:function(data){
		        	    		if(data.status=='SUCCESS'){		//성공시 Grid재조회 및 필드 입력항목 초기화
		        	    			if(data.dupFlag == "Y"){
		        	    				Common.Warning(data.message);
		        	    			} else {
		        	    				var url = '/covicore/control/goGuideMessagePopup.do?messageType=subscription';
			        	    			Common.open("","guideMessagePopup",Common.getDic("lbl_SubscriptionSettingsLocation"),url,"500px","430px","iframe",true,null,null,true);
		        	    			}
		        	    			if(!$('#btnSubscription').hasClass('active')){
		        	    				$('#btnSubscription').addClass('active');
		        	    			}
		        	    		}else{
		        	    			Common.Warning(Common.getDic('msg_apv_030'));//오류가 발생헸습니다.
		        	    		}
		        	    	},
		        	    	error:function(response, status, error){
		        	    	     CFN_ErrorAjax("/covicore/subscription/addSubscription.do", response, status, error);
		        	    	}
		        	    });
		            }
		        });
					
			},
			imgError: function(image) {
			    image.onerror = "";
//			    image.src = Common.getBaseConfig('ProfileImagePath').replace("/{0}", "")+"noimg.png";
			    image.src = "/covicore/resources/images/no_image.jpg";
			    return true;
			},
			renderSubscriptionList: function( pRowData, pProfilePath){
				var liWrapBox= $('<li/>').append('<div class="subscriptionListBox"/>');
				var divPhoto = $('<div class="subStPhoto"/>').append($('<img/>').attr('src', coviCmn.loadImage(pRowData.PhotoPath)).attr('onerror',"coviCtrl.imgError(this, true);"));
				var divContent = $('<div class="subStContent"/>');
				var ulButton = $('<ul class="sbListComment clearFloat mt20"/>');
				var url = '';
				//제목, 본문요약, 일시
				if(pRowData.TargetServiceType == "Board"){
					//게시판 상세보기로 이동
					url = String.format("/groupware/board/goBoardViewPopup.do?CLBIZ=Board&menuID={0}&version={1}&folderID={2}&messageID={3}&viewType=Popup", pRowData.MenuID, pRowData.SecondaryID,  pRowData.TargetID, pRowData.PrimaryID);
					divContent.append($('<a onclick="coviCtrl.goSubscribePopup(\'Board\',\''+url+'\')" />').append(
							$('<p class="sbTit"/>').text(pRowData.Subject), 
							$('<p class="sbTxt desc"/>').text($('<div>').html(pRowData.Description).text())));
					if(pRowData.FileID != undefined && pRowData.FileID != "")
						divContent.append($('<img />').attr('src', Common.getThumbSrc("Board", pRowData.FileID)));
				} else if(pRowData.TargetServiceType == "Schedule"){
					//일정관리 상세보기 페이지 이동
					url = String.format("/groupware/schedule/goScheduleDetailPopup.do?CLSYS=schedule&CLMD=user&CLBIZ=Schedule&eventID={0}&dateID={1}&repeatID={2}&isRepeat={3}&folderID={4}&viewType=Popup&CFN_OpenLayerName=schedule_detail_pop",pRowData.PrimaryID, pRowData.SecondaryID, pRowData.RepeatID, pRowData.IsRepeat, pRowData.TargetID)
					divContent.append($('<a onclick="coviCtrl.goSubscribePopup(\'Schedule\',\''+url+'\')"/>').append(
							$('<p class="sbTit"/>').text(pRowData.Subject), 
							pRowData.Place != ""?$('<p class="sbTxt"/>').text(Common.getDic("lbl_Place") + ': ' +pRowData.Place):"",
							$('<p class="sbTxt"/>').text(Common.getDic("lbl_sch_Startdate") + ': ' + pRowData.StartDate),
							$('<p class="sbTxt"/>').text(Common.getDic("lbl_sch_EndDate") + ': ' +pRowData.EndDate),
							$('<p class="sbTxt desc"/>').html(pRowData.Description)));
				}
				
				//폴더명, 작성자, 작성일시
				divContent.append($('<p class="sbInfo mt15"/>').append(
						$('<span class="colorTheme"/>').text(pRowData.FolderName), 
						$('<span />').text(pRowData.RegisterName),
						$('<span />').text(CFN_TransLocalTime(pRowData.CreateDate, _ServerDateFormat))
					)
				);
				
				//좋아요, 댓글
				ulButton.append(
						$('<li/>').append(
								$('<div class="comHeart heartType02 active"/>').append(
										$('<a class="selected"/>').append(
												$('<i class="fa fa-heart-o fa-2x" aria-hidden="true"/>'),
												Common.getDic("lbl_Good"),
												$('<span data-emoticon="heart"/>').text(pRowData.RecommendCnt)
										)
								)
						),
						$('<li/>').append(
								$('<div class="comCount comCountType02 active"/>').append(
										$('<span class="icon"/>').text(Common.getDic("lbl_Comments")),
										$('<span class="count"/>').text(pRowData.CommentCnt)
								)
						)
				);
				divContent.append(ulButton);
				
				liWrapBox.find('.subscriptionListBox').append(divPhoto, divContent);
				
				return liWrapBox;
			},
			
			//구독 조회 및 그리기
			getSubscriptionList: function(){
				$.ajax({
        	    	type:"POST",
        	    	url:"/covicore/subscription/getTargetList.do",
        	    	data:{
        	    	},
        	    	success:function(data){
        	    		$('.subscriptionListCont').html("");
        	    		if(data!= undefined && data.list!= undefined && data.list.length > 0){
        	    			var ulContainer = $('<ul/>').attr("class", "subscriptionListCont");
        	    			$.each(data.list, function(i, item){
        	    				var innerHTML = coviCtrl.renderSubscriptionList(data.list[i], Common.getBaseConfig('ProfileImagePath',1).replace("{0}", Common.getSession("DN_Code")));
        	    				ulContainer.append(innerHTML);
        	    			});
        	    			$('#divSubscriptionList').html(ulContainer);
        	    		} else {
        	    			$('#divSubscriptionList').html('<p class="noSearchListCont">'+ Common.getDic("msg_NoDataList") +'</p>');
        	    		}
        	    	},
        	    	error:function(response, status, error){
        	    	     CFN_ErrorAjax("/covicore/subscription/getTargetList.do", response, status, error);
        	    	}
        	    });
			},
			
			//구독 목록 정보 조회
			getSubscriptionFolderList: function(){
				var targetServiceType = CFN_GetQueryString("CLBIZ");
				var params = {};
				var folderList = [];
				
				if(targetServiceType == "Schedule"){	//일정관리는 체크박스 형태이므로 별도 parameter 생성
					params["targetServiceType"] = targetServiceType
            	}
				
				$.ajax({
        	    	type:"POST",
        	    	url:"/covicore/subscription/getFolderList.do",
        	    	data:params,
        	    	async:false,
        	    	success:function(data){
        	    		if(data.list.length > 0){
        	    			folderList = data.list
        	    			
        	    			//일정관리 화면에서의 구독버튼 체크박스 선택용
        	    			if(targetServiceType == "Schedule"){
        	    				$('.subscriptionPopList input[type=checkbox]').prop('checked', false);
        	    				$.each(folderList, function(i, item){
        	    					$('.subscriptionPopList input[value=' + item.FolderID + ']').prop('checked', true);
        	    				});
        	    				
        	    			}
        	    		}
        	    	},
        	    	error:function(response, status, error){
        	    	     CFN_ErrorAjax("/covicore/subscription/getFolderList.do", response, status, error);
        	    	}
        	    });
				return folderList;
			},
			
			//즐겨찾기 메뉴 추가
			addFavoriteMenu : function( pMenuID, pFolderID){  //pServiceType: Schedule, pTargetID: FolderID
				var targetID, targetObjectType;
				var targetServiceType = CFN_GetQueryString("CLBIZ");
				if(targetServiceType == "Schedule"){	//일정관리는 체크박스 형태이므로 별도 parameter 생성
					var targetIDs = '';
					targetObjectType = "FD";
            		$(".favoritePopList input[type=checkbox]:checked").each(function(){
            			targetIDs += $(this).attr('value')+";";
            		});
            		
            		if(targetIDs.length > 0){
            			targetID = targetIDs.substring(0,targetIDs.length-1);
            		}
            	} else {
            		if(pFolderID != null && pFolderID != "undefined"){
            			targetID = pFolderID;
            			targetObjectType = 'FD';
            		} else {
            			targetID = pMenuID;
            			targetObjectType = targetObjectType = 'MN';
            		}
            	}
            	
            	if(targetID == "undefined" || targetID == ""){
            		Common.Warning("즐겨찾기 메뉴에 추가할 항목을 선택해주세요.");
            		return;
            	}
				
				Common.Confirm(Common.getDic("msg_AddFavoritesMenu"), 'Confirmation Dialog', function (result) {
		            if (result) {
		            	$.ajax({
		        	    	type:"POST",
		        	    	url:"/covicore/favorite/create.do",
		        	    	data:{
		        	    		"targetServiceType": targetServiceType	//BizSection: Scheudle, Board, Doc, Community ...
		        	    		,"targetObjectType": targetObjectType	//MN, FD
		        	    		,"targetID"	: targetID
		        	    		,"targetURL": $(location).prop("pathname") + $(location).prop("search")
		        	    	},
		        	    	success:function(data){
		        	    		if(data.status=='SUCCESS'){			//성공시 즐겨찾기 메뉴 재조회
		        	    			if(data.dupFlag == "Y"){
		        	    				Common.Inform(data.message);
		        	    			} else {
		        	    				var url = '/covicore/control/goGuideMessagePopup.do?messageType=bookmark';
			        	    			Common.open("","guideMessagePopup",Common.getDic("lbl_FavoriteSettingsLocation"),url,"500px","430px","iframe",true,null,null,true);
		        	    			}
		        	    			coviCtrl.getFavoriteMenuList();
		        	    			if(!$('#btnFavoriteMenu').hasClass('active')){
		        	    				$('#btnFavoriteMenu').addClass('active');
		        	    			}
		        	    		}else{
		        	    			Common.Warning(Common.getDic('msg_apv_030'));//오류가 발생헸습니다.
		        	    		}
		        	    	},
		        	    	error:function(response, status, error){
		        	    	     CFN_ErrorAjax("/covicore/favorite/create.do", response, status, error);
		        	    	}
		        	    });
		            }
		        });
			},
			
			goSubscribePopup: function (serviceType, url){
				
				switch(serviceType.toUpperCase()){
				case 'BOARD' : 
					Common.open("", "board_detail_pop", "상세보기", url, "1050px", "600px", "iframe", true, null, null, true);
					break;
				case 'SCHEDULE' : 
					Common.open("","schedule_detail_pop","상세보기",url,"1050px","635px","iframe",true,null,null,true);
					break;
				}
			},
			
			deleteFavoriteMenu: function( pObj ){
				Common.Confirm(Common.getDic("msg_DeleteFavoritesMenu"), 'Confirmation Dialog', function (result) {
			        if (result) {
						$.ajax({
					    	type:"POST",
					    	url:"/covicore/favorite/delete.do",
					    	async:false,
					    	data:{
					        	'favoriteID': $(pObj).prev().attr('id')
					    	},
					    	success:function(data){
					        	if(data.status == 'SUCCESS'){
					        		Common.Warning(Common.getDic('msg_50'));		//삭제됐습니다.
					        		$(pObj).closest("li").remove();
					        		coviCtrl.getFavoriteMenuList();
					            } else {
					            	Common.Warning(Common.getDic('msg_apv_030'));	//오류가 발생헸습니다.
					            }
					    	},
					    	error:function(response, status, error){
					    	     CFN_ErrorAjax("/covicore/favorite/delete.do", response, status, error);
					    	}
					    });
			        }
				});
			},
			
			//즐겨찾기 메뉴 조회 및 그리기
			getFavoriteMenuList: function(){
				$.ajax({
        	    	type:"POST",
        	    	url:"/covicore/favorite/getList.do",
        	    	data:{
        	    	},
        	    	success:function(data){
        	    	    document.getElementById('my_content_favorite').innerHTML='';
        	    		if(data.status == 'SUCCESS') {
        	    			if (data.list.length > 0){
        	    				$.each(data.list, function(i, item){
	        	    				var displayName = item.DisplayName;
	        	    				if(item.TargetObjectType == "MN"){
	        	    					var boardType = item.TargetURL!= "" ?item.TargetURL.match('[\\&]boardType=([^&#]*)')[1]:"";
	        	    					if(boardType == "MyOwnWrite"){
	        	    						displayName = Common.getDic('lbl_MyWriteMsg');
	        	    					} else if(boardType == "Scrap"){
	        	    						displayName = Common.getDic('lbl_ScrapBoard');
	        	    					} else if(boardType == "Total"){
	        	    						displayName = "전체 글 보기";
	        	    					} else if(boardType == "OnWriting"){
	        	    						displayName = Common.getDic('lbl_OnWritingBoard');
	        	    					} else if(boardType == "Approval"){
	        	    						displayName = Common.getDic('lbl_ApprovalReq');
	        	    					} else if(boardType == "RequestModify"){
	        	    						displayName = Common.getDic('lbl_RequestModifyList');
	        	    					}else if(boardType == "MyBooking"){
	        	    						displayName = Common.getDic('lbl_MyBookingList');
	        	    					}
	        	    				}
	        	    				var outerHTML = '<li><div class="ui_chip">'+
	                	            '<a class="chip_label" id="'+item.FavoriteID+'" href="'+item.TargetURL+'" '+(item.TargetURL.indexOf('CSMU') > -1?"target=_blank":"")+'>'+displayName+'</a>'+
	        						'<button type="button" class="chip_action" onclick="javascript:coviCtrl.deleteFavoriteMenu(this);return false;"><span>삭제</span></button>'+
	        						'</div></li>';
	        	    				
		            	    	    document.getElementById('my_content_favorite').innerHTML+=outerHTML;
	        	    			});
	        	    		}
        	    		} 
        	    	},
        	    	error:function(response, status, error){
        	    	     CFN_ErrorAjax("/covicore/favorite/getList.do", response, status, error);
        	    	}
        	    });
			},
			
			// 연락처 조회 및 그리기
			getContactNumberList: function() {
				$.ajax({
        	    	type:"POST",
        	    	url:"/covicore/contact/getNumberList.do",
        	    	data:{},
        	    	success:function(data) {
        	    		$('#contactNumberDiv').empty();
        	    		
        	    		var html = '<div class="favoriteTopMenuCont oderScrollcont">';
        	    		html += '<div class="favTopMenuBody">';
        	    		html += '<div>';
        	    		html += '<ul class="favTopContactList mt15">';

        	    		if ( data!= undefined && data.list!= undefined && data.list.length > 0) {
        	    			$.each(data.list, function(i, v){
								var sRepJobTypeConfig = Common.getBaseConfig("RepJobType");
						        var sRepJobType = v.MultiJobLevelName;
						        if(sRepJobTypeConfig == "PN"){
						        	sRepJobType = v.MultiJobPositionName;
						        } else if(sRepJobTypeConfig == "TN"){
						        	sRepJobType = v.MultiJobTitleName;
						        } else if(sRepJobTypeConfig == "LN"){
						        	sRepJobType = v.MultiJobLevelName;
						        }
        	    				html += '<li>';
        	    				html += '<div class="personBox">';
        	    				html += '<a class="btnPerBoxMore"></a>';
        	    				html += '<a class="btnListRemove" style="position:absolute;top:10px;right:35px;" onclick="coviCtrl.deleteFavoriteContact(\''+v.SelectedType+'\',\''+v.SelectedCode+'\')"/>';
        	    				html += '<div class="perPhoto">';
        	    				html += '<img src="' + coviCmn.loadImage(v.PhotoPath) + '" style="width:100%;height:100%;" onerror="coviCmn.imgError(this, true);" alt="프로필사진">';
        	    				html += '</div>';
        	    				html += '<div class="name">';
        	    				html += '<p><a style="cursor:default;"><strong>' + v.DisplayName + ' ' + sRepJobType + '</strong></a></p>';
        	    				html += '<p><span>' + v.infoText + '</span></p>';
        	    				
        	    				// TODO CP 메일 작성창 연결 페이지 만들어지면 연결되도록 수정
        	    				html += '<p class="favEmailCont"><span>' + v.MailAddress + '</span></p>';
        	    				/*if(Common.getBaseConfig("isUseMail") == "Y"){
        	    					html += '<p class="favEmailCont"><a class="favEmail" onclick="coviCtrl.clickFavoriteContactMail(\'' + v.DisplayName + '\',\'' + v.MailAddress + '\');">' + v.MailAddress + '</a></p>';
        	    				}else{
        	    					html += '<p class="favEmailCont"><span>' + v.MailAddress + '</span></p>';
        	    				}*/
        	    				
        	    				html += '<p class="hidden"><span class="favTel">' + v.intPhoneNumber + '</span></p>';
        	    				html += '<p class="hidden"><span class="favTel">' + v.intMobile +'</span></p>';
        	    				/*html += '<p class="hidden btnFavListbox mt10"><a class="btnCycleMail"></a>';*/
        	    				if(Common.getGlobalProperties("lync.chat.used") == "Y"){	//lync, skype 채팅 사용시 sip메일 연동
        	    					html += '<a href="sip:' + v.MailAddress + '" class="btnCycleBalloon"></a>';
        	    				} 
        	    				html += '</p>';
        	    				html += '</div>	';
        	    				html += '</div>';
        	    				html += '</li>';
        	    			});
        	    		}
        	    		html += '</ul>';
        	    		html += '</div>';
        	    		if( data == undefined || data.list.length == 0){
        	    			html += '<p class="noSearchListCont">' + Common.getDic("msg_NoDataList") + '</p>';
        	    		}
        	    		html += '</div>';
        	    		html += '</div>';
        	    		
        	    		$('#contactNumberDiv').append(html);
        	    	},
        	    	error:function(response, status, error){
        	    	     CFN_ErrorAjax("/covicore/contact/getNumberList.do", response, status, error);
        	    	}
        	    });
			},
			
			// TODO 조회 및 그리기
			getTodoList: function() {
				$.ajax({
        	    	type:"POST",
        	    	url:"/covicore/todo/getList.do",
        	    	data:{},
        	    	success:function(data) {
        	    		var list = data.list;
        	    		var len = list.length;
        	    		var completeCnt = 0;
        	    		
        	    		$('#todoDiv .todoListCont').empty();
        	    		
        	    		var className = '';
        	    		var html ='';
        	    		/*var html = '<div class="todoContTop clearFloat">';
        	    		html += '<div class="chkStyle04 todoTopChk chkType01">';
        	    		html += '<input type="checkbox" id="allChkInput" class="allChkInput"><label for="allChkInput"><span></span>' + Common.getDic("lbl_AllCompleted") + '</label>';
        	    		html += '</div>';
        	    		html += '<div class="todoTopSelect">';
        	    		html += '</div>';
        	    		html += '<div class="todoBtnBox">';        	    		
        	    		html += '<a class="btnRemoveType02" onclick="coviCtrl.callDeleteTodo(0)">완료목록삭제</a>';
        	    		html += '<a class="btnTodoWrite" onclick="coviCtrl.callWriteTodoPopup(0)">쓰기</a>';
        	    		html += '<a class="btnRepeatType02" onclick="coviCtrl.getTodoList()">리피트</a>';
        	    		html += '</div>';
        	    		html += '</div>';
        	    		html += '<div class="todoContBottom oderScrollcont">';
        	    		html += '<ul class="todoListCont ">';*/
        	    		if (len > 0) {
        	    			$.each(list, function(i, v) {
        	    				var messageType = v.MessageType;
        	    				var isComplete = v.IsComplete;
        	    				switch (messageType) {
	  								case "Mail" : className = "todoListMail"; break;
	  								case "Report" : className = "todoListReport"; break;
	  								case "ChekList" : className = "todoListChekList"; break;
	  								case "Meeting" : className = "todoListMeeting"; break;
	  								case "Reservation" : className = "todoListReservation"; break;
	  								case "ClubShc" : className = "todoListClubShc"; break;
	  								case "Work" : case "Survey" : case "Tab" :  className = "todoListWork"; break;
	  								default : className = ""; break;
								}
        	    				if (isComplete == 'Y') {
        	    					className += ' active';
        	    					
        	    					html += '<li class="clearFloat ' + className +'">';
            	    				html += '<div class="chkStyle04 todoBottomChk chkType01">';
            	    				html += '<input type="checkbox" class="indiChkInput" id="' + 'ccc' + (i + 1) + '" value="' + v.TodoID + '" checked><label for="' + 'ccc' + (i + 1) + '"><span></span></label>';
            	    				
        	    					completeCnt++;
        	    				} else {
        	    					html += '<li class="clearFloat ' + className +'">';
            	    				html += '<div class="chkStyle04 todoBottomChk chkType01">';
            	    				html += '<input type="checkbox" class="indiChkInput" id="' + 'ccc' + (i + 1) + '" value="' + v.TodoID + '"><label for="' + 'ccc' + (i + 1) + '"><span></span></label>';
        	    				}
        	    				html += '</div>';
        	    				if (messageType == 'Tab') {
        	    					html += '<a class="todTitle" onclick="coviCtrl.callWriteTodoPopup(' + v.TodoID + ')" title="' + v.Title +'">';
        	    				} else {
        	    					html += '<a class="todTitle" onclick="window.open(\'' + v.URL + '\', \'_blank\')">';
        	    				}
        	    				html += '<p class="tit">' + v.Title + '</p>';
        	    				html += '<p class="todoInfo"><span class="date">' + v.modifyDateText + '</span></p>';
        	    				html += '</a>';
        	    				html += '</li>';
        	    			});
            	    		$('#todoDiv .todoListCont').append(html);
        	    		}
//        	    		html += '</ul>';
//        	    		html += '</div>';
        	    		
        	    		
        	    		var cntHtml = '';
        	    		if (len == 0) {
            	    		$('#todoDiv .noSearchListCont').show();
        	    			cntHtml = '<a><span>To-Do</span><span class="countStyle"></span></a>';
        	    			
        	    			$("label[for='allChkInput']").html('<span></span>' + Common.getDic("lbl_AllCompleted"));
        	    			$('#allChkInput').prop('checked', false);
        	    		} else {
            	    		$('#todoDiv .noSearchListCont').hide();
        	    			if (len == completeCnt) {
        	    				cntHtml = '<a><span>To-Do</span><span class="countStyle"></span></a>';
        	    				
        	    				$("label[for='allChkInput']").html('<span></span>' + Common.getDic("lbl_apv_releaseall"));
        	    				$('#allChkInput').prop('checked', true);
        	    			} else {
        	    				var cnt = (len - completeCnt) > 99 ? '99+' : (len - completeCnt);
        	    				cntHtml = '<a><span>To-Do</span><span class="countStyle new">' + cnt + '</span></a>';
        	    			}
        	    		}
        	    		
        	    		$('.iconTodo').html(cntHtml);	// 탭 카운트
        	    	},
        	    	error:function(response, status, error){
        	    	     CFN_ErrorAjax("/covicore/todo/getList.do", response, status, error);
        	    	}
        	    });
			},			
			
			callSubscriptionPopup: function(){	//구독 목록 관리
				Common.open("","subscriptionConfigPopup",Common.getDic("lbl_manageSubscription") ,"/covicore/subscription/goConfigPopup.do","703px","425px","iframe",true,null,null,true);
			},
			
			callTopMenuManagePopup: function(){	//메인메뉴 설정
				Common.open("", "topMenuManagePopup", Common.getDic("lbl_setMainMenu"), "/groupware/menu/goTopMenuManagePopup.do?", "400px", "385px", "iframe", true, null, null, true);
			},
			
			callSharePopup : function(url, title){  //공유버튼의 하위 버튼들을 눌렀을 경우 action이 적용되는 함수
				Common.open("","sharePopup",title ,url,"500px","500px","iframe",true,null,null,true);
			},
			
			// Todo 쓰기
			callWriteTodoPopup: function(todoId){
				Common.open("","subscriptionTodoPopup",Common.getDic("lbl_ToDoWrite") ,"/covicore/subscription/goWriteTodoPopup.do?todoId=" + todoId,"600px","280px","iframe",true,null,null,true);
			},
			
			// Todo 삭제
			callDeleteTodo: function(todoId){
				Common.Confirm(Common.getDic("msg_CompleteDelete"), "Inform",function(result) {
					if(result==true){						
						$.ajax({
							url: "/covicore/subscription/deleteTodo.do",
							type: "POST",
							data: {todoId : todoId},
							success:function(data) {
								if(data.status=="SUCCESS"){
									if(todoId==0){
										coviCtrl.getTodoList();
									}else{
										parent.coviCtrl.getTodoList();
										Common.Close();
									}
								}					
							},
							error:function(response, status, error){
								CFN_ErrorAjax("/covicore/todo/getList.do", response, status, error);
							}
						});
					}else{
						return false;
					}
				});	
			},
			/*
			 * selPicker로 데이터를 세팅하는 경우
			 */
			getHWMY : function(parentId, mode, useCalendarPicker, elem){
				/*
				 * 시작 시간으로 끝 시간을 설정할 것인지, 끝 시간으로 시작 시간을 선택할 것인지의 옵션
				 * default는 시작시간으로 끝 시간을 정해주는 것이므로, 끝 시간으로 시작시간을 선택할 경우만 mode를 end라고 입력한다.
				 * 
				 */
				if(useCalendarPicker == undefined)
					useCalendarPicker = 'Y';
					
				//시작 시간
				var $startHourSel = $('#' + parentId + " [name=startHour] select");
				var $endHourSel = $('#' + parentId + " [name=endHour] select");
				var $startMinuteSel = $('#' + parentId + " [name=startMinute] select");
				var $endMinuteSel = $('#' + parentId + " [name=endMinute] select");
				
				var returnData = coviCtrl.getDataByParentId(parentId);
				var selPicker = returnData.selPicker; //선택된 시간을 가져옴
				var startDate = returnData.startDate;
				var startTime;
				if(returnData.startTime == undefined && returnData.startHour != undefined && returnData.startMinute != undefined){
					startTime = returnData.startHour + ':' + returnData.startMinute;
				} else{
					startTime = returnData.startTime;
				}
				var endDate = returnData.endDate;	
				var endTime;
				if(returnData.endTime == undefined && returnData.endHour != undefined && returnData.endMinute != undefined){
					endTime = returnData.endHour + ':' + returnData.endMinute;
				} else{
					endTime = returnData.endTime;
				}
				
				//선택이 선택되었을 경우는 원래 값 그대로
				if(selPicker == "select"){
					if( startDate != undefined && endDate != undefined){
												
						if(startDate > endDate) {
							if(mode == "end"){
								$("#"+parentId+" [name = endDate] input").val(startDate);
							} else if(mode == "start"){
								$("#"+parentId+" [name = startDate] input").val(endDate);
							}
							
							endDate = startDate;
						}
						
						if(startDate == endDate && startTime > endTime){
							if(mode == "end"){
								coviCtrl.setSelected(parentId+' [name=endHour]', coviCtrl.getSelected(parentId+' [name=startHour]').val);
							coviCtrl.setSelected(parentId+' [name=endMinute]', coviCtrl.getSelected(parentId+' [name=startMinute]').val);
							} else if(mode == "start"){
								coviCtrl.setSelected(parentId+' [name=startHour]', coviCtrl.getSelected(parentId+' [name=endHour]').val);
							coviCtrl.setSelected(parentId+' [name=startMinute]', coviCtrl.getSelected(parentId+' [name=endMinute]').val);
							}
						}
						/*if(new Date(startDate.replaceAll(".", "/")).getTime() == new Date(endDate.replaceAll(".", "/")).getTime()){
							if(new Date(startDate.replaceAll(".", "/") + " " + startTime).getTime() > new Date(endDate.replaceAll(".", "/") + " " + endTime).getTime()){
								Common.Warning(Common.getDic("msg_EndDateCannotBeforeStartDate"));	//종료일은 시작일 보다 먼저일 수 없습니다.
								
								coviCtrl.setSelected(parentId+' [name=startDate]', endTime);
								
								if($startHourSel.length != 0 && $startMinuteSel.length != 0){
									coviCtrl.setSelected(parentId+' [name=startHour]', endTime.split(":")[0]);
									coviCtrl.setSelected(parentId+' [name=startMinute]', endTime.split(":")[1]);
								}
							}
						}*/
					}
					return;//JSYUN 선택일 경우, 
				}
					
				if(useCalendarPicker == 'Y' && mode != 'endtime' && startDate == undefined) return;
				
				if(mode != 'endtime' && startDate!=undefined) //달력픽커가 있을 경우
					startDate = startDate.split('.');
				
				if(mode != 'endtime' && endDate!=undefined) //달력픽커가 있을 경우
					endDate = endDate.split('.');
				
				if(startTime!=undefined) //시간픽커가 있을 경우
					startTime = startTime.split(':');
				
				if(endTime!=undefined) //시간픽커가 있을 경우
					endTime = endTime.split(':');
				
				var selPicker_time = selPicker.substring(0, selPicker.length-1);
				var selPicker_type = selPicker.substring(selPicker.length-1,selPicker.length)
				
				if(useCalendarPicker == "N"){
					var date = new Date(CFN_GetLocalCurrentDate(_StandardServerDateFormat));
					
					switch(selPicker_type){
					
					case 'H' :
						if(startTime != undefined && startTime!= ""){  //시간 픽커 선택시 하루가 넘어갈 경우
							/*//if((parseInt(selPicker_time)+parseInt(startTime[0]))/24>0){
								date.setDate(date.getDate()+((parseInt(selPicker_time)+parseInt(startTime[0]))/24));
							//}
							var time = coviCtrl.setTimePickerFormat(((parseInt(selPicker_time)+parseInt(startTime[0]))%24), 2)+':'+coviCtrl.setTimePickerFormat(startTime[1], 2);							
							coviCtrl.setSelected(parentId+' [name=endDate]', time);*/
							
							if($endHourSel.length != 0 && $endMinuteSel.length != 0){
								coviCtrl.setSelected(parentId+' [name=endHour]', coviCtrl.setTimePickerFormat((parseInt(selPicker_time)+parseInt(coviCtrl.getSelected(parentId+' [name=startHour]').val))%24, 2));
								coviCtrl.setSelected(parentId+' [name=endMinute]', coviCtrl.getSelected(parentId+' [name=startMinute]').val);
							}
						}
						
						break;
					case 'W' :
						break;
					case 'M' :
						break;
					case 'Y' : 
						break;
					}
				}else if(mode=="start"){ //start데이터를 세팅(시작시간에 대한 유효성만 체크) -> 시작시간이 종료시간보다 클 경우만 해당되는 경우(유효성체크 필요 없음)					
					var date = (endDate != undefined && endDate != "") ? new Date(endDate[0]+'/'+endDate[1]+'/'+endDate[2]) : new Date(CFN_GetLocalCurrentDate(_StandardServerDateFormat));
					
					if(endDate == undefined || endDate == "") {
						var parseDate = date.getFullYear()+'.'+(coviCtrl.setTimePickerFormat(date.getMonth()+1, 2))+'.'+(coviCtrl.setTimePickerFormat(date.getDate(), 2));
						$("#"+parentId+" [name = startDate] input").val(parseDate);
					}
					
					switch(selPicker_type){
					case 'H' :
						if(endTime != undefined && endTime!= ""){  //시간 픽커 선택시 하루가 넘어갈 경우
							if((parseInt(endTime[0]) - parseInt(selPicker_time)) < 0){
								date.setDate(date.getDate() - 1);
								
								var time = coviCtrl.setTimePickerFormat(((24 - parseInt(selPicker_time))%24), 2)+':'+coviCtrl.setTimePickerFormat(endTime[1], 2);							
								coviCtrl.setSelected(parentId+' [name=startDate]', time);
								
								if($startHourSel.length != 0 && $startMinuteSel.length != 0){
									coviCtrl.setSelected(parentId+' [name=startHour]', coviCtrl.setTimePickerFormat(24 - parseInt(selPicker_time), 2));
									coviCtrl.setSelected(parentId+' [name=startMinute]', coviCtrl.getSelected(parentId+' [name=endMinute]').val);
								}
								
							} else {
								date.setDate(date.getDate());
								
								var time = coviCtrl.setTimePickerFormat(((parseInt(endTime[0]) - parseInt(selPicker_time))%24), 2)+':'+coviCtrl.setTimePickerFormat(endTime[1], 2);							
								coviCtrl.setSelected(parentId+' [name=startDate]', time);
								
								if($startHourSel.length != 0 && $startMinuteSel.length != 0){
									coviCtrl.setSelected(parentId+' [name=startHour]', coviCtrl.setTimePickerFormat(parseInt(coviCtrl.getSelected(parentId+' [name=endHour]').val) - parseInt(selPicker_time), 2));
									coviCtrl.setSelected(parentId+' [name=startMinute]', coviCtrl.getSelected(parentId+' [name=endMinute]').val);
								}
							}
						}
						
						break;
						
					case 'W' :
						date.setDate(date.getDate() - 7*selPicker_time);
						coviCtrl.setSelected(parentId+' [name=startDate]',  coviCtrl.getSelected(parentId+' [name=endDate]').val);
						if($startHourSel.length != 0 && $startMinuteSel.length != 0 &&
								$endHourSel.length != 0 && $endMinuteSel.length != 0){
							coviCtrl.setSelected(parentId+' [name=startHour]',  coviCtrl.getSelected(parentId+' [name=endHour]').val);
							coviCtrl.setSelected(parentId+' [name=startMinute]',  coviCtrl.getSelected(parentId+' [name=endMinute]').val);
						}
						break; 
						
					case 'M' : 
						date.setMonth(date.getMonth() - parseInt(selPicker_time));
						coviCtrl.setSelected(parentId+' [name=startDate]',  coviCtrl.getSelected(parentId+' [name=endDate]').val);
						if($startHourSel.length != 0 && $startMinuteSel.length != 0 &&
								$endHourSel.length != 0 && $endMinuteSel.length != 0){
							coviCtrl.setSelected(parentId+' [name=startHour]',  coviCtrl.getSelected(parentId+' [name=endHour]').val);
							coviCtrl.setSelected(parentId+' [name=startMinute]',  coviCtrl.getSelected(parentId+' [name=endMinute]').val);
						}
						break;
					case 't' : //ehjeong 종료일 체크 시 시작일 변경X
						return;
						break;	
					case 'Y' : 
						date.setYear(date.getFullYear() - parseInt(selPicker_time));
						coviCtrl.setSelected(parentId+' [name=startDate]',  coviCtrl.getSelected(parentId+' [name=endDate]').val);
						if($startHourSel.length != 0 && $startMinuteSel.length != 0 &&
								$endHourSel.length != 0 && $endMinuteSel.length != 0){
							coviCtrl.setSelected(parentId+' [name=startHour]',  coviCtrl.getSelected(parentId+' [name=endHour]').val);
							coviCtrl.setSelected(parentId+' [name=startMinute]',  coviCtrl.getSelected(parentId+' [name=endMinute]').val);
						}
					}
					
					var parseDate = date.getFullYear()+'.'+(coviCtrl.setTimePickerFormat(date.getMonth()+1, 2))+'.'+(coviCtrl.setTimePickerFormat(date.getDate(), 2));
					$("#"+parentId+" [name = startDate] input").val(parseDate);
					$("#"+parentId+" [name = endDate] input").val(endDate[0]+'.'+endDate[1]+'.'+endDate[2]);

				}else if(mode=="end"){
					var date = (startDate != undefined && startDate != "") ? new Date(startDate[0]+'/'+startDate[1]+'/'+startDate[2]) : new Date(CFN_GetLocalCurrentDate(_StandardServerDateFormat));
					
					if(startDate == undefined || startDate == "") {
						var parseDate = date.getFullYear()+'.'+(coviCtrl.setTimePickerFormat(date.getMonth()+1, 2))+'.'+(coviCtrl.setTimePickerFormat(date.getDate(), 2));
						$("#"+parentId+" [name = startDate] input").val(parseDate);
					}
					
					switch(selPicker_type){
						case 'H' :
							if(startTime != undefined && startTime!= ""){  //시간 픽커 선택시 하루가 넘어갈 경우
								//if((parseInt(selPicker_time)+parseInt(startTime[0]))/24>0){
									date.setDate(date.getDate()+((parseInt(selPicker_time)+parseInt(startTime[0]))/24));
								//}
								var time = coviCtrl.setTimePickerFormat(((parseInt(selPicker_time)+parseInt(startTime[0]))%24), 2)+':'+coviCtrl.setTimePickerFormat(startTime[1], 2);							
								coviCtrl.setSelected(parentId+' [name=endDate]', time);
								
								if($endHourSel.length != 0 && $endMinuteSel.length != 0){
									coviCtrl.setSelected(parentId+' [name=endHour]', coviCtrl.setTimePickerFormat((parseInt(selPicker_time)+parseInt(coviCtrl.getSelected(parentId+' [name=startHour]').val))%24, 2));
									coviCtrl.setSelected(parentId+' [name=endMinute]', coviCtrl.getSelected(parentId+' [name=startMinute]').val);
								}
							}
							
							break;
							
						case 'W' :
							date.setDate(date.getDate() + 7*selPicker_time);
							coviCtrl.setSelected(parentId+' [name=endDate]',  coviCtrl.getSelected(parentId+' [name=startDate]').val);
							if($startHourSel.length != 0 && $startMinuteSel.length != 0 &&
									$endHourSel.length != 0 && $endMinuteSel.length != 0){
								coviCtrl.setSelected(parentId+' [name=endHour]',  coviCtrl.getSelected(parentId+' [name=startHour]').val);
								coviCtrl.setSelected(parentId+' [name=endMinute]',  coviCtrl.getSelected(parentId+' [name=startMinute]').val);
							}
							break; 
							
						case 'M' : 
							date.setMonth(date.getMonth() + parseInt(selPicker_time));
							coviCtrl.setSelected(parentId+' [name=endDate]',  coviCtrl.getSelected(parentId+' [name=startDate]').val);
							if($startHourSel.length != 0 && $startMinuteSel.length != 0 &&
									$endHourSel.length != 0 && $endMinuteSel.length != 0){
								coviCtrl.setSelected(parentId+' [name=endHour]',  coviCtrl.getSelected(parentId+' [name=startHour]').val);
								coviCtrl.setSelected(parentId+' [name=endMinute]',  coviCtrl.getSelected(parentId+' [name=startMinute]').val);
							}
							break;
							
						case 'Y' : 
							date.setYear(date.getFullYear()+ parseInt(selPicker_time));
							coviCtrl.setSelected(parentId+' [name=endDate]',  coviCtrl.getSelected(parentId+' [name=startDate]').val);
							if($startHourSel.length != 0 && $startMinuteSel.length != 0 &&
									$endHourSel.length != 0 && $endMinuteSel.length != 0){
								coviCtrl.setSelected(parentId+' [name=endHour]',  coviCtrl.getSelected(parentId+' [name=startHour]').val);
								coviCtrl.setSelected(parentId+' [name=endMinute]',  coviCtrl.getSelected(parentId+' [name=startMinute]').val);
							}
					}
					
					var parseDate = date.getFullYear()+'.'+(coviCtrl.setTimePickerFormat(date.getMonth()+1, 2))+'.'+(coviCtrl.setTimePickerFormat(date.getDate(), 2));
					$("#"+parentId+" [name = startDate] input").val(startDate[0]+'.'+startDate[1]+'.'+startDate[2]);
					$("#"+parentId+" [name = endDate] input").val(parseDate);
					
				}
			},
			getDataByParentId : function(parentId){
				if(coviCtrl.getSelected(parentId+' [name=startHour]').val != undefined){
					var startDate = $('#'+parentId+' [name=startDate] input').val();//시작 달력
					var endDate = $('#'+parentId+' [name=endDate] input').val();//끝 달력
					
					var startHour = coviCtrl.getSelected(parentId+' [name=startHour]').val;
					var endHour = coviCtrl.getSelected(parentId+' [name=endHour]').val;
					
					var startMinute = coviCtrl.getSelected(parentId+' [name=startMinute]').val;
					var endMinute = coviCtrl.getSelected(parentId+' [name=endMinute]').val;
					
					var selPicker = coviCtrl.getSelected(parentId+' [name=datePicker]').val;
					
					var returnData = {
							startDate : startDate,
							endDate : endDate,
							startHour : startHour,
							endHour : endHour,
							startMinute : startMinute,
							endMinute : endMinute,
							selPicker : selPicker
					}
					return returnData;
				}
					
				var startTime = coviCtrl.getSelected(parentId+' [name=startDate]').val;//시작 시간
				var endTime = coviCtrl.getSelected(parentId+' [name=endDate]').val;//종료 시간
				
				var startDate = $('#'+parentId+' [name=startDate] input').val();//시작 달력
				var endDate = $('#'+parentId+' [name=endDate] input').val();//끝 달력
				
				if(startDate == "" || startDate == undefined || startDate == null){
					var date = new Date(CFN_GetLocalCurrentDate(_StandardServerDateFormat));
					var month = date.getMonth()+1 < 10 ? '0'+(date.getMonth()+1) : date.getMonth()+1;
					var day = date.getDate() < 10 ? '0' + date.getDate() : date.getDate();
					startDate = date.getFullYear() +'.'+ month +'.'+ day;
				}
				
				var selPicker = coviCtrl.getSelected(parentId+' [name=datePicker]').val;
				
				var returnData = {
						startDate : startDate,
						endDate : endDate,
						startTime : startTime,
						endTime : endTime,
						selPicker : selPicker
				}
				return returnData;
			},
			renderDateSelect : function(target, timeInfos, initInfos){
				var changeTarget; // select 박스 변경 시 바뀔 항목 선택 (start/end)
				
				if(initInfos.changeTarget=="" || initInfos.changeTarget == undefined){
					changeTarget = 'end';
				}else{
					changeTarget = initInfos.changeTarget;
				}
				
				var dateInfos = {
					codeGroup : ''
				}
				
				//set locale
				var sessionLang = Common.getSession("lang");
				if(typeof sessionLang != "undefined" && sessionLang != ""){
					coviCtrl.variables.lang = sessionLang;
				}
				
				var json = '[';
				var hourData = timeInfos.H.split(',');
				var weekData = timeInfos.W.split(',');
				var monthData = timeInfos.M.split(',');
				var yearData = timeInfos.Y.split(',');
				
				if(hourData[0] != ""){
					dateInfos.defaultVal = hourData[0]+'H';
				}else if(weekData[0] != ""){
					dateInfos.defaultVal = weekData[0]+'W';
				}else if(monthData[0] != ""){
					dateInfos.defaultVal = monthData[0]+'M';
				}else if(yearData[0] != ""){
					dateInfos.defaultVal = yearData[0]+'Y';
				}
				json += '{"CodeName" : "' + CFN_GetDicInfo(coviCtrl.dictionary.select, coviCtrl.variables.lang) + '", "CodeGroup" : "datePicker", "MultiCodeName" : "'+ coviCtrl.dictionary.select +'", "Code" : "select"}';
				for(var j=0;j<hourData.length;j++){
					if(hourData[j] != "")
						json += ',{"CodeName" : "' + hourData[j] + CFN_GetDicInfo(coviCtrl.dictionary.hour, coviCtrl.variables.lang)+ '", "CodeGroup" : "datePicker", "MultiCodeName" : "'+hourData[j] + CFN_GetDicInfo(coviCtrl.dictionary.hour, coviCtrl.variables.lang) +'", "Code" : "'+hourData[j]+'H"}';
				}
				
				for(var j=0;j<weekData.length;j++){
					if(weekData[j] != "")
						json += ',{"CodeName": "' + weekData[j]+ CFN_GetDicInfo(coviCtrl.dictionary.week, coviCtrl.variables.lang) + '", "CodeGroup" : "datePicker", "MultiCodeName" : "'+weekData[j]+ CFN_GetDicInfo(coviCtrl.dictionary.week, coviCtrl.variables.lang)+'", "Code" : "'+weekData[j]+'W"}';
				}
				
				for(var j=0;j<monthData.length;j++){
					if(monthData[j] != "")
						json += ',{"CodeName" : "' + monthData[j] + CFN_GetDicInfo(coviCtrl.dictionary.month, coviCtrl.variables.lang) + '", "CodeGroup" : "datePicker", "MultiCodeName" : "'+monthData[j] + CFN_GetDicInfo(coviCtrl.dictionary.month, coviCtrl.variables.lang)+'", "Code" : "'+monthData[j]+'M"}';
				}
				
				for(var j=0;j<yearData.length;j++){
					if(yearData[j] != "")
						json += ',{"CodeName" : "' + yearData[j]+ CFN_GetDicInfo(coviCtrl.dictionary.year, coviCtrl.variables.lang) + '", "CodeGroup" : "datePicker", "MultiCodeName" : "'+yearData[j]+ CFN_GetDicInfo(coviCtrl.dictionary.year, coviCtrl.variables.lang)+'", "Code" : "'+yearData[j]+'Y"}';
				}
				json+=']';
				
				var timeInfo = JSON.parse(json);
				
				//dateInfos.onclick= 'coviCtrl.selPickerChange';
				var html = coviCtrl.makeSelectData(timeInfo, dateInfos, sessionLang);
				$('#' + target).html("<span name='datePicker' style=''>" + html + "</span>");
				
				$('#' + target + " [name=datePicker] select").change(function(){
					coviCtrl.getHWMY(target, changeTarget, initInfos.useCalendarPicker);
				});
				
				html = coviCtrl.makeCalendarPicker(target, initInfos);
				$('#' + target).append(html);
				$("#" + target + "_StartDate").datepicker({
					dateFormat: 'yy.mm.dd',
				    showOn: 'button',
				    buttonText : 'calendar',
				    buttonImage: Common.getGlobalProperties("css.path") +  "/covicore/resources/images/theme/blue/app_calendar.png", 
	                buttonImageOnly: true,
	                onSelect : function(selected) {
	                	// onSelect 함수에  validation 위치시킬 경우 달력 컨트롤 사용하지 않고 바꾼 값에 대해서는 validaion 체크 안먹음
	                	$("#" + target + "_StartDate").trigger('change');		// change 호출
	                }
				});
				
				$("#" + target + "_EndDate").datepicker({
					dateFormat: 'yy.mm.dd',
				    showOn: 'button',
				    buttonText : 'calendar',
				    buttonImage: Common.getGlobalProperties("css.path") +  "/covicore/resources/images/theme/blue/app_calendar.png", 
	                buttonImageOnly: true,
	                onSelect : function(selected){
	                	// onSelect 함수에  validation 위치시킬 경우 달력 컨트롤 사용하지 않고 바꾼 값에 대해서는 validaion 체크 안먹음
	                	$("#" + target + "_EndDate").trigger('change');		// change 호출
	                }
				});
				
				//시작 시간
				if($('#' + target + " [name=startHour] select") != undefined){
					$('#' + target + " [name=startHour] select").change(function(){
						coviCtrl.getHWMY(target, "end", initInfos.useCalendarPicker);
					});
				}
				//끝 시간
				if($('#' + target + " [name=endHour] select") != undefined){
					$('#' + target + " [name=endHour] select").change(function(){
						coviCtrl.getHWMY(target, "start", initInfos.useCalendarPicker);
					});
				}
				
				//시작 분
				if($('#' + target + " [name=startMinute] select") != undefined){
					$('#' + target + " [name=startMinute] select").change(function(){
						coviCtrl.getHWMY(target, "end", initInfos.useCalendarPicker);
					});
				}
				//끝 분
				if($('#' + target + " [name=endMinute] select") != undefined){
					$('#' + target + " [name=endMinute] select").change(function(){
						coviCtrl.getHWMY(target, "start", initInfos.useCalendarPicker);
					});
				}
				
				//시작 타임
				if($('#' + target + " [name=startDate] select") != undefined){
					$('#' + target + " [name=startDate] select").change(function(){
						coviCtrl.getHWMY(target, "end", initInfos.useCalendarPicker);
					});
				}
				//끝 타임
				if($('#' + target + " [name=endDate] select") != undefined){
					$('#' + target + " [name=endDate] select").change(function(){
						coviCtrl.getHWMY(target, "start", initInfos.useCalendarPicker);
					});
				}
				
				//calendar
				if(initInfos.useCalendarPicker.toUpperCase() == 'Y'){
					$( "#" + target + " [name = startDate] input").change(function(){
						var returnData = coviCtrl.getDataByParentId(target);
						var selPicker = returnData.selPicker; //선택된 시간을 가져옴	
						
						var $start = $("#" + target + "_StartDate");
						var $end = $("#" + target + "_EndDate");

						if($start.val() == ""){
							return;
						}
						
						var dateRegexp = RegExp(/^\d{4}.(0[1-9]|1[012]).(0[1-9]|[12][0-9]|3[01])$/);
						
						if(!dateRegexp.test($start.val())){ // IE에서 "." 포맷을 Date로 변환하는 경우 오류 발생하여 수정함
							$start.val("");
							$end.val("");
							
							Common.Warning(Common.getDic("msg_invalidDateFormat")); //날짜 형식이 올바르지 않습니다.
						}else{
							var startDate = new Date($start.val().replaceAll(".", "/"));
		                	var endDate = new Date($end.val().replaceAll(".", "/"));
							
							if (startDate.getTime() > endDate.getTime()){
		                		$("#" + target + "_EndDate").val(startDate.format('yyyy.MM.dd'));
		                	}
		                	
							if(selPicker != "select"){
								coviCtrl.getHWMY(target, "end", initInfos.useCalendarPicker);
							}
						}
					});
					
					$( "#" + target + " [name = endDate] input").change(function(){
						var returnData = coviCtrl.getDataByParentId(target);
						var selPicker = returnData.selPicker; //선택된 시간을 가져옴	
						
						var $start = $("#" + target + "_StartDate");
						var $end = $("#" + target + "_EndDate");

						if($end.val() == ""){
							return;
						}
						
						var dateRegexp = RegExp(/^\d{4}.(0[1-9]|1[012]).(0[1-9]|[12][0-9]|3[01])$/);
						if(!dateRegexp.test($end.val())){ // IE에서 "." 포맷을 Date로 변환하는 경우 오류 발생하여 수정함
							$start.val("");
							$end.val("");
							
							Common.Warning(Common.getDic("msg_invalidDateFormat")); //날짜 형식이 올바르지 않습니다.
						}else{
							var startDate = new Date($start.val().replaceAll(".", "/"));
		                	var endDate = new Date($end.val().replaceAll(".", "/"));
		                	
							if (startDate.getTime() > endDate.getTime()){		                		
		                		$("#" + target + "_StartDate").val(endDate.format('yyyy.MM.dd'));
		                	}
		                	
							if(selPicker != "select"){
								coviCtrl.getHWMY(target, "start", initInfos.useCalendarPicker);
							}
						}
					});
				}
				
				coviCtrl.setCalendar(target, changeTarget);
				coviInput.setDate();
			},
			renderDateSelect2 : function(target, initInfos){
				var changeTarget; // select 박스 변경 시 바뀔 항목 선택 (start/end)

				if(initInfos.changeTarget=="" || initInfos.changeTarget == undefined){
					changeTarget = 'end';
				}else{
					changeTarget = initInfos.changeTarget;
				}
				
				
				var dateInfos = {
					codeGroup : ''
				}
				
				//set locale
				var sessionLang = Common.getSession("lang");
				if(typeof sessionLang != "undefined" && sessionLang != ""){
					coviCtrl.variables.lang = sessionLang;
				}
				
				//dateInfos.onclick= 'coviCtrl.selPickerChange';
				var html = "";
				
				html = coviCtrl.makeCalendarPicker(target, initInfos);
				$('#' + target).append(html);
				$("#" + target + "_StartDate").datepicker({
					dateFormat: 'yy.mm.dd',
				    showOn: 'button',
				    buttonText : 'calendar',
				    buttonImage: Common.getGlobalProperties("css.path") +  "/covicore/resources/images/theme/blue/app_calendar.png", 
	                buttonImageOnly: true,
	                onSelect : function(selected) {
	                	// onSelect 함수에  validation 위치시킬 경우 달력 컨트롤 사용하지 않고 바꾼 값에 대해서는 validaion 체크 안먹음
	                	$("#" + target + "_StartDate").trigger('change');		// change 호출
	                }
				}).on("change", function() {
					var $start = $("#" + target + "_StartDate");
					var $end = $("#" + target + "_EndDate");

					if($start.val() == ""){
						return;
					}
					
					var dateRegexp = /[0-9]{4}[.][0-9]{2}[.][0-9]{2}/;
					
					if(!dateRegexp.test($start.val())){ // IE에서 "." 포맷을 Date로 변환하는 경우 오류 발생하여 수정함
						$start.val("");
						$end.val("");
						
						Common.Warning(Common.getDic("msg_invalidDateFormat")); //날짜 형식이 올바르지 않습니다.
					}else{
						var startDate = new Date($start.val().replaceAll(".", "/"));
	                	var endDate = new Date($end.val().replaceAll(".", "/"));
						
						if (startDate.getTime() > endDate.getTime()){
	                		$("#" + target + "_EndDate").val(startDate.format('yyyy.MM.dd'));
	                	}
					}
				});
				
				$("#" + target + "_EndDate").datepicker({
					dateFormat: 'yy.mm.dd',
				    showOn: 'button',
				    buttonText : 'calendar',
				    buttonImage: Common.getGlobalProperties("css.path") +  "/covicore/resources/images/theme/blue/app_calendar.png", 
	                buttonImageOnly: true,
	                onSelect : function(selected){
	                	// onSelect 함수에  validation 위치시킬 경우 달력 컨트롤 사용하지 않고 바꾼 값에 대해서는 validaion 체크 안먹음
	                	$("#" + target + "_EndDate").trigger('change');		// change 호출
	                }
				}).on("change", function() {
					var $start = $("#" + target + "_StartDate");
					var $end = $("#" + target + "_EndDate");

					if($end.val() == ""){
						return;
					}
					
					var dateRegexp = /[0-9]{4}[.][0-9]{2}[.][0-9]{2}/;
					
					if(!dateRegexp.test($end.val())){ // IE에서 "." 포맷을 Date로 변환하는 경우 오류 발생하여 수정함
						$start.val("");
						$end.val("");
						
						Common.Warning(Common.getDic("msg_invalidDateFormat")); //날짜 형식이 올바르지 않습니다.
					}else{
						var startDate = new Date($start.val().replaceAll(".", "/"));
	                	var endDate = new Date($end.val().replaceAll(".", "/"));
	                	
						if (startDate.getTime() > endDate.getTime()){		                		
	                		$("#" + target + "_StartDate").val(endDate.format('yyyy.MM.dd'));
	                	}
					}
				});
				
				//시간 변경 시 
				$('#' + target + " select").change(function(){
					var $startHourSel = $('#' + target + " [name=startHour] select");
					var $endHourSel = $('#' + target + " [name=endHour] select");
					var $startMinuteSel = $('#' + target + " [name=startMinute] select");
					var $endMinuteSel = $('#' + target + " [name=endMinute] select");
					
					var returnData = coviCtrl.getDataByParentId(target);
					var selPicker = returnData.selPicker; //선택된 시간을 가져옴
					var startDate = returnData.startDate;
					var startTime;
					if(returnData.startTime == undefined && returnData.startHour != undefined && returnData.startMinute != undefined){
						startTime = returnData.startHour + ':' + returnData.startMinute;
					} else{
						startTime = returnData.startTime;
					}
					var endDate = returnData.endDate;	
					var endTime;
					if(returnData.endTime == undefined && returnData.endHour != undefined && returnData.endMinute != undefined){
						endTime = returnData.endHour + ':' + returnData.endMinute;
					} else{
						endTime = returnData.endTime;
					}
					
					if( startDate != undefined && endDate != undefined && startTime != undefined && endTime != undefined) {
						if(new Date(startDate.replaceAll(".", "/")).getTime() == new Date(endDate.replaceAll(".", "/")).getTime()){
							if(new Date(startDate.replaceAll(".", "/") + " " + startTime).getTime() > new Date(endDate.replaceAll(".", "/") + " " + endTime).getTime()){
								coviCtrl.setSelected(target+' [name=startDate]', endTime);
								
								if($startHourSel.length != 0 && $startMinuteSel.length != 0){
									coviCtrl.setSelected(target+' [name=startHour]', endTime.split(":")[0]);
									coviCtrl.setSelected(target+' [name=startMinute]', endTime.split(":")[1]);
								}
							}
						}
					}
				});
				
				
				coviInput.setDate();
			},
			renderDateSelect3 : function(target, initInfos, num){
				var changeTarget; // select 박스 변경 시 바뀔 항목 선택 (start/end)

				if(initInfos.changeTarget=="" || initInfos.changeTarget == undefined){
					changeTarget = 'end';
				}else{
					changeTarget = initInfos.changeTarget;
				}

				var dateInfos = {
					codeGroup : ''
				}

				//set locale
				var sessionLang = Common.getSession("lang");
				if(typeof sessionLang != "undefined" && sessionLang != ""){
					coviCtrl.variables.lang = sessionLang;
				}

				//dateInfos.onclick= 'coviCtrl.selPickerChange';
				var html = "";

				html = coviCtrl.makeCalendarPicker(target, initInfos);
				$('#' + target).append(html);
				$("#" + target + "_StartDate").datepicker({
					dateFormat: 'yy.mm.dd',
					showOn: 'button',
					buttonText : 'calendar',
					buttonImage: Common.getGlobalProperties("css.path") +  "/covicore/resources/images/theme/blue/app_calendar.png",
					buttonImageOnly: true,
					onSelect : function(selected) {
						// onSelect 함수에  validation 위치시킬 경우 달력 컨트롤 사용하지 않고 바꾼 값에 대해서는 validaion 체크 안먹음
						$("#" + target + "_StartDate").trigger('change');		// change 호출
					}
				}).on("change", function() {
					var $start = $("#" + target + "_StartDate");
					var $end = $("#" + target + "_EndDate");

					if($start.val() == ""){
						return;
					}

					var dateRegexp = /[0-9]{4}[.][0-9]{2}[.][0-9]{2}/;
					//if(!dateRegexp.test($start.val()) || isNaN(Date.parse($start.val()))){
					if(!dateRegexp.test($start.val())){ // IE에서 "." 포맷을 Date로 변환하는 경우 오류 발생하여 수정함
						$start.val("");
						$end.val("");

						Common.Warning(Common.getDic("msg_invalidDateFormat")); //날짜 형식이 올바르지 않습니다.
					}else{
						var startDate = new Date($start.val().replaceAll(".", "/"));
						var endDate = new Date($end.val().replaceAll(".", "/"));
						var duplicateCheck = false;
						if(num>0){//중복 일 체크 2022-03-28 nkpark
							for(var i=0;i<num;i++){
								var $tstart = $("#period" + i + "_StartDate");
								var $tend = $("#period" + i + "_EndDate");
								if($tstart.val()==="" || $tend.val()===""){
									continue;
								}
								var tstartDate = new Date($tstart.val().replaceAll(".", "/"));
								var tendDate = new Date($tend.val().replaceAll(".", "/"));
								if( (startDate >= tstartDate && startDate <=tendDate)
									|| (endDate >= tstartDate && endDate <=tendDate)
								){
									duplicateCheck = true;
								}
							}
						}
						if(duplicateCheck){
							Common.Warning("이미 등록된 날짜 입니다.");
							$start.val("");
							$end.val("");
						}else if  (startDate.getTime() > endDate.getTime()){
							$("#" + target + "_EndDate").val(startDate.format('yyyy.MM.dd'));
						}
					}
				});

				$("#" + target + "_EndDate").datepicker({
					dateFormat: 'yy.mm.dd',
					showOn: 'button',
					buttonText : 'calendar',
					buttonImage: Common.getGlobalProperties("css.path") +  "/covicore/resources/images/theme/blue/app_calendar.png",
					buttonImageOnly: true,
					onSelect : function(selected){
						// onSelect 함수에  validation 위치시킬 경우 달력 컨트롤 사용하지 않고 바꾼 값에 대해서는 validaion 체크 안먹음
						$("#" + target + "_EndDate").trigger('change');		// change 호출
					}
				}).on("change", function() {
					var $start = $("#" + target + "_StartDate");
					var $end = $("#" + target + "_EndDate");

					if($end.val() == ""){
						return;
					}

					var dateRegexp = /[0-9]{4}[.][0-9]{2}[.][0-9]{2}/;
					if(!dateRegexp.test($end.val())){ // IE에서 "." 포맷을 Date로 변환하는 경우 오류 발생하여 수정함
						$start.val("");
						$end.val("");

						Common.Warning(Common.getDic("msg_invalidDateFormat")); //날짜 형식이 올바르지 않습니다.
					}else{
						var startDate = new Date($start.val().replaceAll(".", "/"));
						var endDate = new Date($end.val().replaceAll(".", "/"));

						var duplicateCheck = false;
						if(num>0){//중복 일 체크 2022-03-28 nkpark
							for(var i=0;i<num;i++){
								var $tstart = $("#period" + i + "_StartDate");
								var $tend = $("#period" + i + "_EndDate");
								if($tstart.val()==="" || $tend.val()===""){
									continue;
								}
								var tstartDate = new Date($tstart.val().replaceAll(".", "/"));
								var tendDate = new Date($tend.val().replaceAll(".", "/"));
								if( (startDate >= tstartDate && startDate <=tendDate)
									|| (endDate >= tstartDate && endDate <=tendDate)
								){
									duplicateCheck = true;
								}
							}
						}
						if(duplicateCheck){
							Common.Warning("이미 등록된 날짜 입니다.");
							$start.val("");
							$end.val("");
						}else if (startDate.getTime() > endDate.getTime()){
							$("#" + target + "_StartDate").val(endDate.format('yyyy.MM.dd'));
						}
					}
				});

				//시간 변경 시
				$('#' + target + " select").change(function(){
					var $startHourSel = $('#' + target + " [name=startHour] select");
					var $endHourSel = $('#' + target + " [name=endHour] select");
					var $startMinuteSel = $('#' + target + " [name=startMinute] select");
					var $endMinuteSel = $('#' + target + " [name=endMinute] select");

					var returnData = coviCtrl.getDataByParentId(target);
					var selPicker = returnData.selPicker; //선택된 시간을 가져옴
					var startDate = returnData.startDate;
					var startTime;
					if(returnData.startTime == undefined && returnData.startHour != undefined && returnData.startMinute != undefined){
						startTime = returnData.startHour + ':' + returnData.startMinute;
					} else{
						startTime = returnData.startTime;
					}
					var endDate = returnData.endDate;
					var endTime;
					if(returnData.endTime == undefined && returnData.endHour != undefined && returnData.endMinute != undefined){
						endTime = returnData.endHour + ':' + returnData.endMinute;
					} else{
						endTime = returnData.endTime;
					}

					if( startDate != undefined && endDate != undefined && startTime != undefined && endTime != undefined) {
						if(new Date(startDate.replaceAll(".", "/")).getTime() == new Date(endDate.replaceAll(".", "/")).getTime()){
							if(new Date(startDate.replaceAll(".", "/") + " " + startTime).getTime() > new Date(endDate.replaceAll(".", "/") + " " + endTime).getTime()){
								coviCtrl.setSelected(target+' [name=startDate]', endTime);

								if($startHourSel.length != 0 && $startMinuteSel.length != 0){
									coviCtrl.setSelected(target+' [name=startHour]', endTime.split(":")[0]);
									coviCtrl.setSelected(target+' [name=startMinute]', endTime.split(":")[1]);
								}
							}
						}
					}
				});


				coviInput.setDate();
			},
			/*
			 * 끝의 달력이 변하는 경우
			 */
			setSelStartDate : function(parentId){
				var returnData = coviCtrl.getDataByParentId(parentId);
				var selPicker = returnData.selPicker;
				var startDate = returnData.startDate;
				var endDate = returnData.endDate; //선택된 시간을 가져옴
				var startTime, endTime, startHour, endHour, startMinute, endMinute;
				
				if(coviCtrl.getSelected(parentId+' [name=startHour]').val != undefined 
						&& coviCtrl.getSelected(parentId+' [name=startHour]').val != "" 
						&& coviCtrl.getSelected(parentId+' [name=startHour]').val != "undefined"){
					startHour = parseInt(returnData.startHour);
					endHour = parseInt(returnData.endHour);	
					startMinute = parseInt(returnData.startMinute);	
					endMinute = parseInt(returnData.endMinute);
				}else{
					startTime = returnData.startTime;	
					endTime = returnData.endTime;
				}
				
				if(startTime == null){
					//timepicker가 만들어지지 않았을 경우
					var startDateArray = startDate.split('.');
					var endDateArray = endDate.split('.');
					
					var startDateObj = new Date(startDateArray[0], Number(startDateArray[1])-1, startDateArray[2]);
					var endTimeObj = new Date(endDateArray[0], Number(endDateArray[1])-1, endDateArray[2]);
					
					//두 날짜 사이의 차이(날짜 차이)
					var dateDiff = (endTimeObj.getTime() - startDateObj.getTime()) / 1000 / 60 / 60 / 24;
					
					//*주 차이인 경우
					if(dateDiff%7 == 0){
						var weekDiff = dateDiff/7;
						//if($('#'+parentId+' [name=datePicker] .selList [data-code='+weekDiff+'W]').text()!=""){
						if($('#' + parentId + ' [name=datePicker] select').val(weekDiff + 'W') != undefined){
							//해당하는 값이 있는 경우 이므로
							coviCtrl.setSelected(parentId+' [name=datePicker]', (weekDiff + 'W'));
							return;
						}
					}
					//startDate = startDate.replace(/\./g, '');
					//endDate =endDate.replace(/\./g, '');
					
					//달차이
					if(startDateArray[2]== endDateArray[2]){
						if(startDateArray[1] == endDateArray[1]){
							//달이 같은 경우
							var yearDiff = endDateArray[0] - startDateArray[0];
							//if($('#' + parentId + ' [name=datePicker] .selList [data-code='+yearDiff+'Y]').text()!=""){
							if($('#' + parentId + ' [name=datePicker] select').val(yearDiff + 'Y') != undefined){	
								//해당하는 값이 있는 경우 이므로
								coviCtrl.setSelected(parentId+' [name=datePicker]', (yearDiff+"Y"));
								return;
							}
						}else{
							//달이 다른 경우
							var monthDiff = endDateArray[1] - startDateArray[1];
							if($('#'+parentId+' [name=datePicker] .selList [data-code='+monthDiff+'M]').text()!=""){
								//해당하는 값이 있는 경우 이므로
								coviCtrl.setSelected(parentId+' [name=datePicker]', (monthDiff+"M"));
								return;
							}
						}
					}
					coviCtrl.setSelected(parentId+' [name=datePicker]', "select");
					return;
				}
				
				//시간과 분이 분리된 컨트롤일 경우
				if(coviCtrl.getSelected(parentId+' [name=startHour]').val != undefined 
						&& coviCtrl.getSelected(parentId+' [name=startHour]').val != "" 
						&& coviCtrl.getSelected(parentId+' [name=startHour]').val != "undefined"){
					if(startDate == endDate){
						//뒷자리가 서로 같은 경우
						var timeDiff = parseInt(endHour)-parseInt(startHour);
						//이럴경우 만약 timeDiffH가 있을 경우, 그것을 선택
						if($('#'+parentId+' [name=datePicker] .selList [data-code='+timeDiff+'H]').text()!=""){
							//해당하는 값이 있는 경우 이므로
							coviCtrl.setSelected(parentId+' [name=datePicker]', (timeDiff+"H"));
							return;
						}				
					}else{
						//날짜를 object(date) 형태로 변환하고,
						var startDateArray = startDate.split('.');
						var endDateArray = endDate.split('.');
						
						var startDateObj = new Date(startDateArray[0], Number(startDateArray[1])-1, startDateArray[2]);
						var endTimeObj = new Date(endDateArray[0], Number(endDateArray[1])-1, endDateArray[2]);
						
						//두 날짜 사이의 차이(날짜 차이)
						var dateDiff = (endTimeObj.getTime() - startDateObj.getTime()) / 1000 / 60 / 60 / 24;
						
						//*주 차이인 경우
						if(dateDiff%7 == 0){
							var weekDiff = dateDiff/7;
							if($('#'+parentId+' [name=datePicker] .selList [data-code='+weekDiff+'W]').text()!=""){
								//해당하는 값이 있는 경우 이므로
								coviCtrl.setSelected(parentId+' [name=datePicker]', (weekDiff+"W"));
								return;
							}
						}
						startDate = startDate.replace(/\./g, '');
						endDate =endDate.replace(/\./g, '');
						
						//달차이
						if(startDateArray[2]== endDateArray[2]){
							if(startDateArray[1] == endDateArray[1]){
								//달이 같은 경우
								var yearDiff = endDateArray[0] - startDateArray[0];
								if($('#'+parentId+' [name=datePicker] .selList [data-code='+yearDiff+'Y]').text()!=""){
									//해당하는 값이 있는 경우 이므로
									coviCtrl.setSelected(parentId+' [name=datePicker]', (yearDiff+"Y"));
									return;
								}
							}else{
								//달이 다른 경우
								var monthDiff = endDateArray[1] - startDateArray[1];
								if($('#'+parentId+' [name=datePicker] .selList [data-code='+monthDiff+'M]').text()!=""){
									//해당하는 값이 있는 경우 이므로
									coviCtrl.setSelected(parentId+' [name=datePicker]', (monthDiff+"M"));
									return;
								}
							}
						}
					}
				}else{
				//달력이 선택된 시간이 같은 경우
					if(startDate == endDate){
						startTime = startTime.split(":");
						endTime = endTime.split(":");
						if(startTime[1] == endTime[1]){
							//뒷자리가 서로 같은 경우
							var timeDiff = parseInt(endTime[0])-parseInt(startTime[0]);
							//이럴경우 만약 timeDiffH가 있을 경우, 그것을 선택
							if($('#'+parentId+' [name=datePicker] .selList [data-code='+timeDiff+'H]').text()!=""){
								//해당하는 값이 있는 경우 이므로
								coviCtrl.setSelected(parentId+' [name=datePicker]', (timeDiff+"H"));
								return;
							}
						}				
					}else{
						//날짜가 다른 경우,
						startTime = startTime.split(":");
						endTime = endTime.split(":");
						//시간이 같은 경우
						if(startTime[0] == endTime[0]){
							if(startTime[1] == endTime[1]){
								//날짜를 object(date) 형태로 변환하고,
								var startDateArray = startDate.split('.');
								var endDateArray = endDate.split('.');
								
								var startDateObj = new Date(startDateArray[0], Number(startDateArray[1])-1, startDateArray[2]);
								var endTimeObj = new Date(endDateArray[0], Number(endDateArray[1])-1, endDateArray[2]);
								
								//두 날짜 사이의 차이(날짜 차이)
								var dateDiff = (endTimeObj.getTime() - startDateObj.getTime()) / 1000 / 60 / 60 / 24;
								
								//*주 차이인 경우
								if(dateDiff%7 == 0){
									var weekDiff = dateDiff/7;
									if($('#'+parentId+' [name=datePicker] .selList [data-code='+weekDiff+'W]').text()!=""){
										//해당하는 값이 있는 경우 이므로
										coviCtrl.setSelected(parentId+' [name=datePicker]', (weekDiff+"W"));
										return;
									}
								}
								startDate = startDate.replace(/\./g, '');
								endDate =endDate.replace(/\./g, '');
								
								//달차이
								if(startDateArray[2]== endDateArray[2]){
									if(startDateArray[1] == endDateArray[1]){
										//달이 같은 경우
										var yearDiff = endDateArray[0] - startDateArray[0];
										if($('#'+parentId+' [name=datePicker] .selList [data-code='+yearDiff+'Y]').text()!=""){
											//해당하는 값이 있는 경우 이므로
											coviCtrl.setSelected(parentId+' [name=datePicker]', (yearDiff+"Y"));
											return;
										}
									}else{
										//달이 다른 경우
										var monthDiff = endDateArray[1] - startDateArray[1];
										if($('#'+parentId+' [name=datePicker] .selList [data-code='+monthDiff+'M]').text()!=""){
											//해당하는 값이 있는 경우 이므로
											coviCtrl.setSelected(parentId+' [name=datePicker]', (monthDiff+"M"));
											return;
										}
									}
								}
							}
						}
						//시간이 다른 경우	
					}
				}
				coviCtrl.setSelected(parentId+' [name=datePicker]', "select");
			},
			endDatePickerChange : function (elem){
				//여기서는 달력 선택시 앞과, 뒤가 변경되는거
				var parentId = $(this).parent().parent().attr("id");
				coviCtrl.setSelStartDate(parentId)
				
			},
			/*
			 * 시간 범위 picker의 액션이 생겼을 경우
			 * 
			 */
			selPickerChange : function(elem){
				var parentId= $(elem).parent().parent().parent().parent().attr("id");//현재 버튼이 존재하는 사용자 지정 div id 값
				coviCtrl.getHWMY(parentId, "end", undefined, elem);
			},
			/*
			 * 처음 캘린더 로드시  시작시간은 현재 날짜, 시간 범위 picker의 범위에 맞게 끝 날짜를 세팅하는 함수
			 * 
			 */
			setCalendar : function(target , changeTarget){
				//$( "#"+target+" [name = startDate] [kind=date]" ).val(new Date().getFullYear()+"."+coviCtrl.setTimePickerFormat(new Date().getMonth()+1, 2)+"."+(coviCtrl.setTimePickerFormat(new Date().getDate(), 2)));
				if(changeTarget == "start"){
					$( "#"+target+" [name = endDate] input" ).val(new Date(CFN_GetLocalCurrentDate(_StandardServerDateFormat)).format('yyyy.MM.dd'));
					coviCtrl.getHWMY(target, "start")
				}else{
					$( "#"+target+" [name = startDate] input" ).val(new Date(CFN_GetLocalCurrentDate(_StandardServerDateFormat)).format('yyyy.MM.dd'));
					coviCtrl.getHWMY(target, "end")
				}
			},
			makeSimpleCalendar : function(target, defaultDate){
				var html = '';
				html += '<span name="date">';
				html += '	<input id="' + target + '_Date" type="text" style="width:80px;">';
				html += '</span>';
				
				$('#' + target).append(html);
				$('#' + target + '_Date').datepicker({
					dateFormat: 'yy.mm.dd',
				    showOn: 'button',
				    buttonText : 'calendar',
				    buttonImage: Common.getGlobalProperties("css.path") +  "/covicore/resources/images/theme/blue/app_calendar.png", 
	                buttonImageOnly: true
				});
				
				if(defaultDate == null){
					$('#' + target + '_Date').datepicker("setDate", new Date(CFN_GetLocalCurrentDate(_StandardServerDateFormat)).format('yyyy.MM.dd'));
				} else {
					$('#' + target + '_Date').datepicker("setDate", defaultDate);
				}
			},
			getSimpleCalendar : function(target){
				return $('#' + target + '_Date').val();
			},
			/*
			 * target : 시작하는 달력이 그려질 위치
			 * type : 달력의 시작인지 끝인지 (start / end)
			 * 시작, 종료일의 캘린더 picker를 만드는 함수
			 */
			makeCalendarPicker : function(target, initInfos){
				var html_startCalendarPicker='';
				var html_endCalendarPicker='';
				var html_startTimePicker='';
				var html_endTimePicker='';
				var returnData = '';
				
				var hourJson='[';
				var minuteJson='[';
				var width = initInfos.hasOwnProperty("width") ? initInfos.width + "px" : "80px";
				
				//달력을 그릴 지 확인
				if(initInfos.useCalendarPicker.toUpperCase() =='Y'){
					///HtmlSite/smarts4j_n/covicore/resources/images/theme/blue/app_calendar.png
					//달력을 그릴 경우
					//html_startCalendarPicker = '<input class="adDate" id="' + target + '_StartDate" date_separator="." kind="date" type="text" data-axbind="date" vali_early="true" vali_date_id="' + target + '_EndDate">';
					//html_endCalendarPicker= '<input class="adDate" id="' + target + '_EndDate" date_separator="." kind="date" type="text" data-axbind="date" vali_late="true" vali_date_id="' + target + '_StartDate">';
					html_startCalendarPicker = '<input id="' + target + '_StartDate" type="text" style="width:'+width+';">';
					html_endCalendarPicker= '<input id="' + target + '_EndDate" type="text" style="width:'+width+';">';
					
					returnData = '<span name="startDate">' + html_startCalendarPicker + '</span>';
					returnData += ' - ';
					returnData += '<span name="endDate">' + html_endCalendarPicker + '</span>';
				}
				
				//시간 선택 픽커를 그릴 경우
				if(initInfos.useTimePicker.toUpperCase() =='Y'){
					
					if(initInfos.useSeparation.toUpperCase() == 'Y'){//시간과 분을 분리할 경우
						
						var startHourPicker;
						var endHourPicker;
						var startMinutePicker;
						var endMinutePicker;
						
						//interval숫자가 60약수가 아닐 경우
						if(60%initInfos.minuteInterval != 0) return;
						
						//시간 select box 그리는 코드
						var hour="";
						for(var hour=0;hour<24;hour+=1){
							hourJson+='{"CodeName" : "'+coviCtrl.setTimePickerFormat(hour,2)+'", "CodeGroup" : "hour", "MultiCodeName" : "'+coviCtrl.setTimePickerFormat(hour,2)+'", "Code" : "'+coviCtrl.setTimePickerFormat(hour,2)+'"},';
						}
						hourJson = hourJson.substr(0, hourJson.length-1);
						hourJson+=']';
						hourJson = JSON.parse(hourJson);
						
						var timeInfos = {
								defaultVal : '00',
								lang : 'ko',
								onclick : 'coviCtrl.startHourChange'
						}
						startHourPicker =  coviCtrl.makeSelectData(hourJson, timeInfos, "ko");
						timeInfos.onclick = 'coviCtrl.endHourChange';
						endHourPicker = coviCtrl.makeSelectData(hourJson, timeInfos, "ko");
							
						//분 select box 그리는 코드
						var minute="";
						for(var minute=0;minute<60;minute+=initInfos.minuteInterval){
							minuteJson+='{"CodeName" : "'+coviCtrl.setTimePickerFormat(minute,2)+'", "CodeGroup" : "minute", "MultiCodeName" : "'+coviCtrl.setTimePickerFormat(minute,2)+'", "Code" : "'+coviCtrl.setTimePickerFormat(minute,2)+'"},';
						}
						if(initInfos.use59 =='Y'){
							minuteJson+='{"CodeName" : "'+59+'", "CodeGroup" : "minute", "MultiCodeName" : "'+59+'", "Code" : "'+59+'"},';
							
						}
						minuteJson = minuteJson.substr(0, minuteJson.length-1);
						minuteJson+=']';
						minuteJson = JSON.parse(minuteJson);
						
						timeInfos = {
								defaultVal : '00',
								lang : 'ko',
								onclick : 'startMinuteChange'
						}
						startMinutePicker =  coviCtrl.makeSelectData(minuteJson, timeInfos, "ko");
						timeInfos.onclick = 'endMinuteChange';
						endMinutePicker = coviCtrl.makeSelectData(minuteJson, timeInfos, "ko");
						
						returnData = '<span name="startDate">'+html_startCalendarPicker+'</span><span name="startHour">'+startHourPicker+'</span><span name="startMinute">'+startMinutePicker+'</span>';
						returnData += ' - ';
						returnData += '<span name="endDate">'+html_endCalendarPicker+'</span><span name="endHour">'+endHourPicker+'</span><span name="endMinute">'+endMinutePicker+'</span>';
					} else {//시간픽커에서 시간과 분을 분리하지 않는 경우
						var minute=0;
						var json='[';
						var hour;
						for(hour=0;hour<24;hour+=0.5){
							minute = coviCtrl.setTimePickerFormat(minute, 2);
							json+='{"CodeName" : "'+coviCtrl.setTimePickerFormat(Math.floor(hour), 2)+':'+minute+'", "CodeGroup" : "timePicker", "MultiCodeName" : "'+coviCtrl.setTimePickerFormat(Math.floor(hour), 2)+':'+minute+'", "Code" : "'+coviCtrl.setTimePickerFormat(Math.floor(hour), 2)+':'+minute+'"},';
							(minute==0)?minute=30:minute=0;
							if(minute == 0){
								if(initInfos.use59 == 'Y'){
									json+='{"CodeName" : "'+coviCtrl.setTimePickerFormat(Math.floor(hour), 2)+':'+59+'", "CodeGroup" : "timePicker", "MultiCodeName" : "'+coviCtrl.setTimePickerFormat(Math.floor(hour), 2)+':'+59+'", "Code" : "'+coviCtrl.setTimePickerFormat(Math.floor(hour), 2)+':'+59+'"},';
								}
							}
						}
						
						json = json.substr(0, json.length-1);
						json+=']';
						var timeInfo = JSON.parse(json);  //00:00 - 23:30 까지의 데이터를 json 형태로 만들어 makeSelectData로 만든다.
						
						var timeInfos = {
								defaultVal : '00:00',
								lang : 'ko',
								onclick:'coviCtrl.startTimeChange'
						}
						//시작시간 시간 픽커의 액션걸기
						html_startTimePicker =  coviCtrl.makeSelectData(timeInfo, timeInfos, "ko");
						
						//종료시간 끝시간 픽커의 액션걸기
						timeInfos.onclick='coviCtrl.endTimeChange';
						html_endTimePicker =  coviCtrl.makeSelectData(timeInfo, timeInfos, "ko");
						
						returnData = '<span name="startDate">' + html_startCalendarPicker + html_startTimePicker + '</span>';
						returnData += ' - ';
						returnData += '<span name="endDate">' + html_endCalendarPicker + html_endTimePicker + '</span>';
					}
				}
				
				return returnData;
			},
			startHourChange : function(elem){
				var parentId = $(elem).parent().parent().parent().parent().attr('id');
				
				coviCtrl.getHWMY(parentId, "end", undefined, elem);
			},
			startMinuteChange : function(elem){
				var parentId = $(elem).parent().parent().parent().parent().attr('id');
				
				coviCtrl.getHWMY(parentId, "end", undefined, elem);
			},
			endHourChange : function(elem){
				var parentId = $(elem).parent().parent().parent().parent().attr('id');
				var returnData = coviCtrl.getDataByParentId(parentId);
				
				var selPicker = returnData.selPicker;
				var startHour = parseInt(returnData.startHour);
				var endHour = parseInt(returnData.endHour);	
				var startMinute = parseInt(returnData.startMinute);	
				var endMinute = parseInt(returnData.endMinute);
				
				//달력은 달력컨트롤 내부에서 유효성 체크 진행됨
				
				//시가 같고 분이 더 큰 경우
				if(selPicker == "select"){//선택으로 되어있을 경우,
					coviCtrl.setSelected(parentId+' [name=endHour]',startHour);
					coviCtrl.setSelected(parentId+' [name=endMinute]',endMinute);
				}
				if(startHour == endHour){
					if(parseInt(startMinute) > parseInt(endMinute)){
						coviCtrl.setSelected(parentId+' [name=endMinute]',  coviCtrl.getSelected(parentId+' [name=startMinute]').val);
					}
				}else{ //뒤의 시간이 더 큰 경우
					if(parseInt(startHour) > parseInt(endHour)){
						coviCtrl.getHWMY(parentId, "end", undefined, elem);
					}
				}
				
				coviCtrl.setSelStartDate(parentId);
			},
			endMinuteChange : function(elem){
				var parentId = $(elem).parent().parent().parent().parent().attr('id');
				
				var returnData = coviCtrl.getDataByParentId(parentId);
				var selPicker = returnData.selPicker;
				var startHour = parseInt(returnData.startHour);
				var endHour = parseInt(returnData.endHour);	
				var startMinute = parseInt(returnData.startMinute);	
				var endMinute = parseInt(returnData.endMinute);
				
				if(selPicker == "select"){//선택으로 되어있을 경우,
					coviCtrl.setSelected(parentId+' [name=endHour]',startHour);
					coviCtrl.setSelected(parentId+' [name=endMinute]',endMinute);
				}
				if(startHour == endHour){
					if(parseInt(startMinute) > parseInt(endMinute)){
						coviCtrl.setSelected(parentId+' [name=endMinute]',  coviCtrl.getSelected(parentId+' [name=startMinute]').val);
					}
				}else{ //뒤의 시간이 더 큰 경우
					if(parseInt(startHour) > parseInt(endHour)){
						coviCtrl.getHWMY(parentId, "end", undefined, elem);
					}
				}
				
				coviCtrl.setSelStartDate(parentId);
//				setSelStartDate(parentId);
			},
			// start, end format: yyyymmdd
			getDifMonths: function (start, end)
			{
			 var startYear = start.substring(0, 4);
			 var endYear = end.substring(0, 4);
			 var startMonth = start.substring(4, 6) - 1;
			 var endMonth = end.substring(4, 6) - 1;
			 var startDay = start.substring(6, 8);
			 var endDay = end.substring(6, 8);

			 // 연도 차이가 나는 경우
			 if (parseInt(startYear,10) > parseInt(endYear,10)) {
			  // 종료일 월이 시작일 월보다 수치로 빠른 경우
			  if (parseInt(startMonth,10) > parseInt(endMonth,10)) {
			   var newEnd = startYear + "1231";
			   var newStart = endYear + "0101";

			   return (parseInt(getDifMonths(start, newEnd),10) + parseInt(getDifMonths(newStart, end)),10).toFixed(2);
			  // 종료일 월이 시작일 월보다 수치로 같거나 늦은 경우
			  } else         {
			   var formMonth = parseInt(startMonth,10) + 1;
			   if (parseInt(formMonth,10) < 10) formMonth = "0" + formMonth;

			   var newStart = endYear + "" + formMonth + "" + startDay;
			   var addMonths = (parseInt(endYear,10) - parseInt(startYear,10)) * 12;

			   return (parseInt(addMonths,10) + parseInt(getDifMonths(newStart, end)),10).toFixed(2);
			  }
			 } else         { 
			  // 월별 일수차 (30일 기준 차이 일수)
			  var difDaysOnMonth = new Array(1, -2, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1);
			  var difDaysTotal = coviCtrl.getDifDays(start, end);

			  for (var i = startMonth; i < endMonth; i++) {
			   if (i == 1 && coviCtrl.isLeapYear(startYear)) difDaysTotal -= (difDaysOnMonth[i] + 1);
			   else         difDaysTotal -= difDaysOnMonth[i];
			  }
			  return (difDaysTotal / 30);
			  }
			},
			
			getDifDays : function(start, end)
			{
			 var dateStart = new Date(start.substring(0, 4), start.substring(4, 6) - 1, start.substring(6, 8));
			 var dateEnd = new Date(end.substring(0, 4), end.substring(4, 6) - 1, end.substring(6, 8));
			 var difDays = (dateEnd.getTime() - dateStart.getTime()) / (24 * 60 * 60 * 1000);

			 // because view this function
			 return Math.ceil(difDays);
			},
			isLeapYear: function(year)
			{
			 // parameter가 숫자가 아니면 false
			 if (isNaN(year))
			  return false;
			 else  {
			  var nYear = parseInt(year,10);

			  // 4로 나누어지고 100으로 나누어지지 않으며 400으로는 나눠지면 true(윤년)
			  if (nYear % 4 == 0 && nYear % 100 != 0 || nYear % 400 == 0)
			   return true;
			  else
			   return false;
			 }
			},
			startTimeChange : function(elem){
				var parentId = $(elem).parent().parent().parent().parent().attr('id');
				
				coviCtrl.getHWMY(parentId, "end", undefined, elem)
			},
			//종료시간 타임 픽커가 변하는 경우(시간, 분 분리 안됨)
			endTimeChange : function(elem){
				var parentId= $(elem).parent().parent().parent().parent().attr("id");//현재 버튼이 존재하는 사용자 지정 div id 값
				
				//날짜 유효성 검사(이전 날짜일 경우 현재 날짜로)
				var returnData = coviCtrl.getDataByParentId(parentId);
				
				var selPicker = returnData.selPicker;
				var endTime = returnData.endTime;
				var startTime = returnData.startTime; 
				//달력은 달력컨트롤 내부에서 유효성 체크 진행됨
				
				
				startTime = startTime.split(':');
				endTime = endTime.split(':');
				if(selPicker == "select"){//선택으로 되어있을 경우,
					coviCtrl.setSelected(parentId+' [name=endDate]',startTime );
				}
				if(startTime[0] == endTime[0]){//시작시간이 같을 경우
					if(parseInt(startTime[1]) > parseInt(endTime[1])) //뒤의 시간(분)이 큰 경우
						coviCtrl.getHWMY(parentId, "end", undefined, elem);
						//coviCtrl.setSelected(parentId+'[name=endTime]',  coviCtrl.getSelected(parentId+' [name=startDate]').val)  //뒤의 시간을 앞의 시간으로 고정
				}else{ //시작시간이 다를 경우
					if(parseInt(startTime[0]) > parseInt(endTime[0])){//뒤의 시간(시)이 더 큰 경우
						coviCtrl.getHWMY(parentId, "end", undefined, elem);
						//coviCtrl.setSelected(parentId+'[name=endTime]', coviCtrl.getSelected(parentId+' [name=startDate]').val)  //뒤의 시간을 앞의 시간으로 고정
					}
				}
				coviCtrl.setSelStartDate(parentId);
			},
			/*
			 * 달력 picker만 생성한 경우, 달력picker 값 변경시 호출되는 함수
 			 * 
			 */
			startDatePickerChange : function(elem){
				var parentId= elem.currentTarget.parentNode.parentNode.getAttribute('id');//현재 버튼이 존재하는 사용자 지정 div id 값
				
				coviCtrl.getHWMY(parentId, "end", initInfos.useCalendarPicker, elem);
				
			},
			setTimePickerFormat : function (n, width){
				 n = n + '';
				  return n.length >= width ? n : new Array(width - n.length + 1).join('0') + n;
			},
			setDateDisable : function(target, initInfos){
				var selPicker = initInfos.selPicker;
				var startCalendar = initInfos.startCalendar;
				var endCalendar = initInfos.endCalendar;
				var startTime = initInfos.startTime;
				var endTime = initInfos.endTime;

				var startHour = initInfos.startHour;
				var endHour = initInfos.endHour;
				var startMinute = initInfos.startMinute;
				var endMinute = initInfos.endMinute;
				
				if(selPicker == 'Y' || selPicker=='y'){
					$("#"+target+" [name=datePicker] .selList").remove();
					$("#"+target+" [name=datePicker] a").css("background", "rgb(235, 235, 228)")
				}
				
				if(startCalendar == 'Y' || startCalendar=='y'){
					$("#"+target+" [name=startDate] a").remove();
					$("#"+target+" [name=startDate] input").attr("disabled", true);
				}
				if(endCalendar == 'Y' || endCalendar=='y'){
					$("#"+target+" [name=endDate] a").remove();
					$("#"+target+" [name=endDate] input").attr("disabled", true);
				}
				
				if(startTime == 'Y' || startTime=='y'){
					$("#"+target+" [name=startDate] .selList").remove();
					$("#"+target+" [name=startDate] a").css("background", "rgb(235, 235, 228)");
				}
				if(endTime == 'Y' || endTime=='y'){
					$("#"+target+" [name=endDate] .selList").remove();
					$("#"+target+" [name=endDate] a").css("background", "rgb(235, 235, 228)");
				}
				
				if(startHour == 'Y' || startHour=='y'){
					$("#"+target+" [name=startHour] .selList").remove();
					$("#"+target+" [name=startHour] a").css("background", "rgb(235, 235, 228)");
				}
				if(endHour == 'Y' || endHour=='y'){
					$("#"+target+" [name=endHour] .selList").remove();
					$("#"+target+" [name=endHour] a").css("background", "rgb(235, 235, 228)");
				}
				if(startMinute == 'Y' || startMinute=='y'){
					$("#"+target+" [name=startMinute] .selList").remove();
					$("#"+target+" [name=startMinute] a").css("background", "rgb(235, 235, 228)");
				}
				if(endMinute == 'Y' || endMinute=='y'){
					$("#"+target+" [name=endMinute] .selList").remove();
					$("#"+target+" [name=endMinute] a").css("background", "rgb(235, 235, 228)");
				}
			},
			/*
			 * 색상 picker를 만드는 함수
			 */
			renderColorPicker : function (target, colorInfos, clearBtnType){
				var html='<input type="text" style="display:none" name="colorPicker" data-palette=[';
				for(var i=0;i<colorInfos.length;i++)
					html+='{"'+Object.keys(colorInfos[i])+'":"'+Object.values(colorInfos[i])+'"},';
				html = html.substr(0, html.length-1);
				
				html+='] value="'+Object.keys(colorInfos[0])+':'+Object.values(colorInfos[0])+'">';
				$('#'+target).html(html);
				
				$('[name="colorPicker"]').paletteColorPicker({
					clear_btn: (clearBtnType == 'N') ? null : (clearBtnType == 'last') ? 'last' : 'first'
				});
			},
			/*
			 * 선택된 색상의 이름 : 16진수 색상값
			 */
			getSelectColor : function(){
				return $('[name="colorPicker"]')[0].value;
			},
			getSelectColorKey : function(){
				return $('[name="colorPicker"]')[0].value.split(':')[0];
			},
			getSelectColorVal : function(){
				return $('[name="colorPicker"]')[0].value.split(':')[1];
			},
			/*
			 * 색상의 초기값 선택 (색상 picker 초기화 시, 넘겼던 색상의 이름/ 없는 색상일 경우 처음 값으로 초기값 세팅됨)
			 */
			setSelectColor : function(colorName){
				$('[name="colorPicker"]').setColorPicker(colorName);
				
				var dataPalette = $.parseJSON($('[name="colorPicker"]').attr("data-palette"));
				var colorVal = "";
				$(dataPalette).each(function(i){
					if($$(this).attr("default") != undefined){
						colorVal = $$(this).attr("default");
					} 
					
					if($$(this).attr(colorName) != undefined){
						colorVal = colorName + ":" + $$(this).attr(colorName);
						return false;
					}
				});
				
				$('[name="colorPicker"]').val(colorVal);
			},
			renderAjaxSelect : function(initInfos, oncomplete, lang){
				$.ajax({
					type:"POST",
					data:{
						"codeGroups" : coviCtrl.makeCodeGroups(initInfos)
					},
					url:"/covicore/basecode/get.do",
					async : false,
					success:function (data) {
						if(data.result == "ok" && data.list != undefined){
							var dataList = data.list;
							var html;
							for(var i = 0; i < initInfos.length; i++) {
								var initInfoObj = initInfos[i];
								var codeGroup = initInfoObj.codeGroup;
								var onchangeFnName = initInfoObj.onchange;
								
								html = coviCtrl.makeSelectData(coviCtrl.getCodeList(codeGroup, dataList), initInfoObj, lang);
								$('#' + initInfoObj.target).html(html);
							}
							
							if(onchangeFnName != null && onchangeFnName != '' && onchangeFnName !="undefined"){
								$('#' + initInfoObj.target + " select").change(function(){
									//callback method 호출
									if(window[onchangeFnName] != undefined){
										window[onchangeFnName]();
									} else if(parent[onchangeFnName] != undefined){
										parent[onchangeFnName]();
									} else if(this[onchangeFnName] != undefined){
										this[onchangeFnName](elem);
									} else if(opener && opener[onchangeFnName] != undefined){
										opener[onchangeFnName]();
									} else{
								        try{
								        	//let changeFunc= new Function(onchangeFnName+"()");
								        	//changeFunc();
								        	coviCmn.callFnBasedNamespace(onchangeFnName);
											
								        }catch(e){coviCmn.traceLog(e)}
									}
								});
							}
							
							//oncomplete
							if(oncomplete != null && oncomplete != ''){
								if(window[oncomplete] != undefined){
									window[oncomplete]();
								} else if(parent[oncomplete] != undefined){
									parent[oncomplete]();
								} else if(opener[oncomplete] != undefined){
									opener[oncomplete]();
								}
							}
						}
					},
					error:function (error){
						alert(error.message);
					}
				});
			},
			renderDomainAXSelect : function(target, lang, onchange, oncomplete, defaultVal, hasAll, options){
				var rtnDomainCode = "";
				$.ajax({
					type:"POST",
					url:"/covicore/domain/getCode.do",
					async:false,
					success:function (data) {
						if(data.result == "ok"){
							if(target == null || target == '' || data.list == null || data.list == undefined){
								return false;
							}
							
							lang = coviCmn.isNull(lang, "");
							
							//var selectOption = coviCtrl.makeAXSelectData(data.list, arrCodeGroup[i], lang);
							/*
					    	 * { optionValue: 'A.SettingKey', optionText:'설정키'}
					    	 * */
							var codeArray = data.list;
					    	var optionArray = new Array();

							if(hasAll){
								optionArray.push({'optionValue':'','optionText': CFN_GetDicInfo("전체;All;すべて;所有;;;;;", (lang != "" ?  lang : "ko" )) }); //도메인
							}
					    	
					    	for(var j = 0; j < codeArray.length; j++) {
					    		var optionObj = new Object();
					    		var codeObj = codeArray[j];
					    		if(defaultVal == codeObj.DomainID) rtnDomainCode = codeObj.DomainCode;
					    		optionObj.optionValue = codeObj.DomainID;
					    		optionObj.optionData = codeObj.DomainCode;
					    		if(options && options.codeType && options.codeType == "CODE"){
									optionObj.optionValue = codeObj.DomainCode;
								}
						    	if(lang == ''){
						    		optionObj.optionText = codeObj.DisplayName;	
						    	} else {
						    		optionObj.optionText = CFN_GetDicInfo(codeObj.MultiDisplayName, lang);	
						    	}
						    	optionArray.push(optionObj);
					    	}
					    	
							$("#" + target).bindSelect({
								reserveKeys: {
									optionValue: "optionValue",
									optionText: "optionText"
								},
								options: optionArray,
								setValue : defaultVal,
								onchange: function(){
									//method 호출
									if(onchange != null && onchange != ''){
										if(window[onchange] != undefined){
											window[onchange](this);
										} else if(parent[onchange] != undefined){
											parent[onchange](this);
										} else if(opener != undefined && opener[onchange] != undefined){
											opener[onchange](this);
										}else{
											//보안취약 조치(eval, Function)
											//let ptFunc = new Function('a', onchange+'(a)');
											//ptFunc(this) ;
											coviCmn.callFnBasedNamespace(onchange, this);
										}
									}
								}
								
							});	
							
							for(var j = 0; j < optionArray.length; j++) {
								$("#" + target).find("option[value='" + optionArray[j].optionValue + "']").attr("code",optionArray[j].optionData);
							}
								
							//method 호출
							if(oncomplete != null && oncomplete != ''){
								if(window[oncomplete] != undefined){
									window[oncomplete]();
								} else if(parent[oncomplete] != undefined){
									parent[oncomplete]();
								} else if(opener[oncomplete] != undefined){
									opener[oncomplete]();
								}
							}
							
						}
					},
					error:function (error){
						alert(error.message);
					}
				});
				return rtnDomainCode;
			},
			
			/* Company 목록 SelectBox 바인딩
			 * target: target Select ID
			 * lang: 다국어 값
			 * hasAll:  { optionValue: '', optionText:'전체'} 추가 여부
			 * onchange: 값 변경 시 호출 함수
			 * oncomplete: 바인딩 완료 시 호출 함수
			 * defaultVal: 기본 선택 값
			 */
			renderCompanyAXSelect : function(target, lang, hasAll, onchange, oncomplete, defaultVal, options){
				var allCompany = Common.getBaseConfig("useAffiliateSearch");
				if(Common.getGlobalProperties("isSaaS") == "Y") {
					// SaaS 그룹웨어의 경우 사간검색 무조건 불가능
					allCompany = "N";
				}
				var isAdmin = CFN_GetQueryString("CLMD") == "undefined" ? parent.CFN_GetQueryString("CLMD") : CFN_GetQueryString("CLMD");
				
				$.ajax({
					type:"POST",
					url:"/covicore/control/getCompanyList.do",
					data:{
						allCompany: allCompany,
						isAdmin : isAdmin
					},
					async:false,
					success:function (data) {
						if(data.status == "SUCCESS"){
							if(target == null || target == '' || data.list == null || data.list == undefined){
								return false;
							}
							
							lang = coviCmn.isNull(lang, "");
							
							//var selectOption = coviCtrl.makeAXSelectData(data.list, arrCodeGroup[i], lang);
							/*
					    	 * { optionValue: 'A.SettingKey', optionText:'설정키'}
					    	 * */
							var codeArray = data.list;
							var optionArray = new Array();

							if(hasAll){
								optionArray.push({'optionValue':'','optionText': CFN_GetDicInfo("전체;All;すべて;所有;;;;;", (lang != "" ?  lang : "ko" )) }); //도메인
							}
							
					    	for(var j = 0; j < codeArray.length; j++) {
					    		var optionObj = new Object();
					    		var codeObj = codeArray[j];
					    		optionObj.optionValue = codeObj.GroupCode;
								if(options && options.codeType && options.codeType == "ID"){
									optionObj.optionValue = codeObj.GroupID;
								}
						    	if(lang == ''){
						    		optionObj.optionText = codeObj.DisplayName;	
						    	} else {
						    		optionObj.optionText = CFN_GetDicInfo(codeObj.MultiDisplayName, lang);
						    	}
						    	optionArray.push(optionObj);
					    	}
					    	
							$("#" + target).bindSelect({
								reserveKeys: {
									optionValue: "optionValue",
									optionText: "optionText"
								},
								options: optionArray,
								setValue : defaultVal,
								onchange: function(){
									//method 호출
									if(onchange != null && onchange != ''){
										if(window[onchange] != undefined){
											window[onchange](this);
										} else if(parent[onchange] != undefined){
											parent[onchange](this);
										} else if(opener[onchange] != undefined){
											opener[onchange](this);
										}
									}
								}
								
							});	
							
							//method 호출
							if(oncomplete != null && oncomplete != ''){
								if(window[oncomplete] != undefined){
									window[oncomplete]();
								} else if(parent[oncomplete] != undefined){
									parent[oncomplete]();
								} else if(opener[oncomplete] != undefined){
									opener[oncomplete]();
								}
							}
							
						}
					},
					error:function (error){
						alert(error.message);
					}
				});
			},
			renderAXSelect : function(pCodeGroups, pTargets, lang, onchange, oncomplete, pDefaultVal, hasAll, expGroup){
				$.ajax({
					type:"POST",
					data:{
						"codeGroups" : pCodeGroups
					},
					url:"/covicore/basecode/get.do",
					async:false,
					success:function (data) {
						if(data.result == "ok"){
							if(pCodeGroups == null || pCodeGroups == '' || pTargets == null || pTargets == ''){
								return false;
							}
							
							var arrCodeGroup = pCodeGroups.split(',');
							var arrTarget = pTargets.split(',');
							var arrOnchange;
							if(onchange != null && onchange != ''){
								arrOnchange = onchange.split(',');	
							}
							var arrDefaultVal;
							if(pDefaultVal != null && pDefaultVal != '' && pDefaultVal != undefined){
								arrDefaultVal = pDefaultVal.split(',');	
							}
							if(expGroup == null || expGroup == undefined) expGroup = false;
							
							
							
							for(var i = 0; i < arrCodeGroup.length; i++) {
								var selectOption = coviCtrl.makeAXSelectData(data.list, arrCodeGroup[i], lang, expGroup);

								if(hasAll){
									selectOption.unshift({'optionValue':'','optionText': CFN_GetDicInfo("전체;All;すべて;所有;;;;;", (lang != "" ?  lang : "ko" )) }); //도메인
								}
								var bindOption = {
										reserveKeys: {
											optionValue: "optionValue",
											optionText: "optionText"
										},
										options: selectOption
									};
								
								if(arrDefaultVal != null){
									bindOption.setValue = arrDefaultVal[i];	
								}
								
								if(arrOnchange != null){
									var onchangeFnName = arrOnchange[i];
									bindOption.onchange = function(){
										if(onchange != null){
											//method 호출
											if(onchangeFnName != null && onchangeFnName != ''){
												if(window[onchangeFnName] != undefined){
													window[onchangeFnName](this);
												} else if(parent[onchangeFnName] != undefined){
													parent[onchangeFnName](this);
												} else if(opener[onchangeFnName] != undefined){
													opener[onchangeFnName](this);
												}
											}
										}
									};
								}
								
								
								$("#" + arrTarget[i]).bindSelect(bindOption);	
							}
							
							//method 호출
							if(oncomplete != null && oncomplete != ''){
								if(window[oncomplete] != undefined){
									window[oncomplete]();
								} else if(parent[oncomplete] != undefined){
									parent[oncomplete]();
								} else if(opener[oncomplete] != undefined){
									opener[oncomplete]();
								}
							}
							
						}
					},
					error:function (error){
						alert(error.message);
					}
				});
			},
			makeAXSelectData : function(dataList, codeGroup, locale, expGroup){
				locale = coviCmn.isNull(locale, "");
				
				for(var i = 0; i < dataList.length; i++) {
				    var obj = dataList[i];
				    if(obj.hasOwnProperty(codeGroup)){
				    	var codeArray = obj[codeGroup];
				    	
				    	/*
				    	 * { optionValue: 'A.SettingKey', optionText:'설정키'}
				    	 * */
				    	var optionArray = new Array();
				    	for(var j = 0; j < codeArray.length; j++) {
				    		var optionObj = new Object();
				    		var codeObj = codeArray[j];
				    		if (expGroup== false || (expGroup == true && codeObj.Code != codeGroup)){
					    		optionObj.optionValue = codeObj.Code;
						    	if(locale == ''){
						    		optionObj.optionText = codeObj.CodeName;	
						    	} else {
						    		optionObj.optionText = CFN_GetDicInfo(codeObj.MultiCodeName, locale);	
						    	}
						    	optionArray.push(optionObj);
				    		}	
				    	}
				    }
				}
				return optionArray;
			},
			makeTreeView : function(dataList, option){//메뉴관리 file Tree selected
				/*
				 * [
				 * 	{
						"MenuID": "260",
						"open": false,
						"__subTree": false,
						"DomainID": "0",
						"IsAdmin": "N",
						"MenuType": "Top",
						"BizSection": "Portal",
						"ParentObjectID": "0",
						"ParentObjectType": "DN",
						"ServiceDevice": "P",
						"DisplayName": "포탈",
						"MultiDisplayName": "포탈;;;;;;;;;;;",
						"MemberOf": "0",
						"MenuPath": "",
						"LinkMenuID": "",
						"SecurityLevel": "90",
						"SortKey": "0",
						"SortPath": "000000000000000;",
						"HasFolder": "N",
						"IsInherited": "Y",
						"IsUse": "Y",
						"IsDisplay": "Y",
						"URL": "",
						"MobileURL": "",
						"Target": "Current",
						"MobileTarget": "",
						"RegisterCode": "SuperAdmin",
						"RegistDate": "2013-02-27 14:20:22.0",
						"ModifierCode": "",
						"ModifyDate": "2013-02-27 14:20:22.0",
						"DeleteDate": "",
						"Reserved1": "",
						"Reserved2": "",
						"Reserved3": "",
						"Reserved4": "",
						"Reserved5": ""
					},.....
				 * ]
				 * 
				 * */
				var treeHTML = '';
				treeHTML += '<div id="sidetreecontrol" style="margin:5px;">';
				treeHTML += '<a href="?#">전체 닫기</a> | <a href="?#">전체 열기</a>';
				treeHTML += '</div>';
				treeHTML += '<ul>';
				treeHTML += '	<li>';
				treeHTML += '		<div style="display:block;border-style:dotted;border-width:1px 0px 1px 0px;">';
				treeHTML += '			<div style="float:left;min-width:300px;display:inline-block;">&nbsp;명칭</div>';
				treeHTML += '			<div style="float:left;min-width:50px;display:inline-block;">&nbsp;메뉴ID</div>';
				treeHTML += '			<div style="float:left;min-width:100px;display:inline-block;">&nbsp;메뉴유형</div>';
				treeHTML += '			<div style="float:left;min-width:100px;display:inline-block;">&nbsp;업무구분</div>';
				treeHTML += '			<div style="float:left;min-width:50px;display:inline-block;">&nbsp;사용여부</div>';
				treeHTML += '			<div style="float:left;min-width:150px;display:inline-block;">&nbsp;수정일</div>';
				treeHTML += '			<div style="float:left;min-width:100px;display:inline-block;">&nbsp;삭제</div>';
				treeHTML += '			<div style="float:left;min-width:100px;display:inline-block;">&nbsp;위로</div>';
				treeHTML += '			<div style="float:left;min-width:100px;display:inline-block;">&nbsp;아래로</div>';
				treeHTML += '			<div style="display:none;clear:both;"></div>';
				treeHTML += '		</div>';
				treeHTML += '	<li>';
				treeHTML += '</ul>';
				treeHTML += '<ul id="tree">';
				treeHTML += '</ul>';
				
				$('#customTree').html(treeHTML);
				
				//1 level rendering
				var oneLevelRemovedObj = new Array();
				var twoLevelRemovedObj = new Array();
				
				for (var i = 0; i < dataList.length; i++) {
					var html = '';
					
					var sortPath = dataList[i].SortPath;
					if(sortPath != null && sortPath != ''){
						var splittedSortPath = sortPath.split(';');
						if(splittedSortPath.length == 2){
							$('#tree').append(coviCtrl.makeRowForTree(dataList[i],'one',splittedSortPath[0]));
						} else {
							oneLevelRemovedObj.push(dataList[i]);
						}
						
					}
				}
				
				for (var i = 0; i < oneLevelRemovedObj.length; i++) {
					var html = '';
					
					var sortPath = oneLevelRemovedObj[i].SortPath;
					if(sortPath != null && sortPath != ''){
						var splittedSortPath = sortPath.split(';');
						if(splittedSortPath.length == 3){
							$('#customTree_one_' + splittedSortPath[0]).append(coviCtrl.makeRowForTree(oneLevelRemovedObj[i],'two',splittedSortPath[1]));
						} else {
							twoLevelRemovedObj.push(oneLevelRemovedObj[i]);
						}
						
					}
				}
				
				for (var i = 0; i < twoLevelRemovedObj.length; i++) {
					var html = '';
					
					var sortPath = twoLevelRemovedObj[i].SortPath;
					if(sortPath != null && sortPath != ''){
						var splittedSortPath = sortPath.split(';');
						if(splittedSortPath.length == 4){
							$('#treeview_two_' + splittedSortPath[1]).append(coviCtrl.makeRowForTree(twoLevelRemovedObj[i],'',''));
						} else {
							//twoLevelRemovedObj.push(oneLevelRemovedObj[i]);
						}
						
					}
				}
				$("#tree").treeview({
	                collapsed: true,
	                animated: "fast",
	                control:"#sidetreecontrol",
	                persist: "location"
	            });
			},
			makeRowForTree : function(obj, level, splittedSortPath){
				var html = '';
				html += '<li>';
				html += '	<div style="display:block;border-style:dotted;border-width:0px 0px 1px 0px;">';
				html += '		<div style="float:left;min-width:300px;display:inline-block;">&nbsp;' + obj.DisplayName + '</div>';
				html += '		<div style="float:left;min-width:50px;display:inline-block;">&nbsp;' + obj.MenuID + '</div>';
				html += '		<div style="float:left;min-width:100px;display:inline-block;">&nbsp;' + obj.MenuType + '</div>';
				html += '		<div style="float:left;min-width:100px;display:inline-block;">&nbsp;' + obj.BizSection + '</div>';
				html += '		<div style="float:left;min-width:50px;display:inline-block;">&nbsp;' + obj.IsUse + '</div>';
				html += '		<div style="float:left;min-width:150px;display:inline-block;">&nbsp;' + obj.ModifyDate + '</div>';
				html += '		<div style="float:left;min-width:100px;display:inline-block;">&nbsp;삭제</div>';
				html += '		<div style="float:left;min-width:100px;display:inline-block;">&nbsp;위로</div>';
				html += '		<div style="float:left;min-width:100px;display:inline-block;">&nbsp;아래로</div>';
				html += '		<div style="display:none;clear:both;"></div>';
				html += '	</div>';
				if(obj.ChildCount != '0' || level != '' || splittedSortPath != ''){
					html += '	<ul id="treeview_' + level + '_' + splittedSortPath + '">';
					html += '	</ul>';
				}
				html += '</li>';
				
				return html;
			},
			//set option
			treeTableConfig : {//트리설정
				target : "",
				sortPathKey : "SortPath",
				drag : "false",
				checkBox : "false",
				useControl : "up,down,add,remove,move",
				cols : [
				        	{colKey : "Name", colName : "명칭"},
				        	{colKey : "Desc", colName : "설명"}
				        ],
				dataAttrs : [],        
				clicked : "",
		        doubleCicked : "",
		        upClicked : "",
		        downClicked : "",
		        dropped : "",
		        addClicked : "",
		        removeClicked : "",
		        moveClicked : ""
			},
			makeTreeTable : function(dataList, option){
				/*
				 * http://ludo.cubicphuse.nl/jquery-treetable/#examples
				 * 
				 * [
				 * 	{
						"MenuID": "260",
						"open": false,
						"__subTree": false,
						"DomainID": "0",
						"IsAdmin": "N",
						"MenuType": "Top",
						"BizSection": "Portal",
						"ParentObjectID": "0",
						"ParentObjectType": "DN",
						"ServiceDevice": "P",
						"DisplayName": "포탈",
						"MultiDisplayName": "포탈;;;;;;;;;;;",
						"MemberOf": "0",
						"MenuPath": "",
						"LinkMenuID": "",
						"SecurityLevel": "90",
						"SortKey": "0",
						"SortPath": "000000000000000;",
						"HasFolder": "N",
						"IsInherited": "Y",
						"IsUse": "Y",
						"IsDisplay": "Y",
						"URL": "",
						"MobileURL": "",
						"Target": "Current",
						"MobileTarget": "",
						"RegisterCode": "SuperAdmin",
						"RegistDate": "2013-02-27 14:20:22.0",
						"ModifierCode": "",
						"ModifyDate": "2013-02-27 14:20:22.0",
						"DeleteDate": "",
						"Reserved1": "",
						"Reserved2": "",
						"Reserved3": "",
						"Reserved4": "",
						"Reserved5": ""
					},.....
				 * ]
				 * 
				 * */
				
				if(option != null){
					coviCtrl.treeTableConfig.target = option.target;
					coviCtrl.treeTableConfig.sortPathKey = option.sortPathKey;
					coviCtrl.treeTableConfig.drag = option.drag;
					coviCtrl.treeTableConfig.checkBox = option.checkBox;
					coviCtrl.treeTableConfig.useControl = option.useControl;
					coviCtrl.treeTableConfig.cols = option.cols;
					coviCtrl.treeTableConfig.dataAttrs = option.dataAttrs;
					coviCtrl.treeTableConfig.clicked = option.clicked;
					coviCtrl.treeTableConfig.doubleClicked = option.doubleClicked;
					coviCtrl.treeTableConfig.upClicked = option.upClicked;
					coviCtrl.treeTableConfig.downClicked = option.downClicked;
					coviCtrl.treeTableConfig.dropped = option.dropped;
					coviCtrl.treeTableConfig.addClicked = option.addClicked;
					coviCtrl.treeTableConfig.removeClicked = option.removeClicked;
					coviCtrl.treeTableConfig.moveClicked = option.moveClicked;
					coviCtrl.treeTableConfig.exportClicked = option.exportClicked;
				}
				
				var treeHTML = '';
				treeHTML += '<table id="treetable_' + coviCtrl.treeTableConfig.target + '">';
				//treeHTML += '<caption>';
				//treeHTML += '<a onclick="jQuery(\'#example-advanced\').treetable(\'expandAll\'); return false;">Expand all</a>';
				//treeHTML += '<a onclick="jQuery(\'#example-advanced\').treetable(\'collapseAll\'); return false;">Collapse all</a>';
				//treeHTML += '</caption>';
				treeHTML += '<colgroup>';
				
				if(coviCtrl.treeTableConfig.checkBox == 'true' || coviCtrl.treeTableConfig.checkBox == true) treeHTML += '<col>';
				for (var i = 0; i < coviCtrl.treeTableConfig.cols.length; i++) {
					var col = coviCtrl.treeTableConfig.cols[i];
					treeHTML += '<col '+(col.colWidth?'width="'+col.colWidth+'"':'')+'>';
				}
				if(coviCtrl.treeTableConfig.useControl != '') treeHTML += '<col width="450px">';
				treeHTML += '</colgroup>';
				
				treeHTML += '<thead>';
				treeHTML += '<tr>';
				if(coviCtrl.treeTableConfig.checkBox == 'true' || coviCtrl.treeTableConfig.checkBox == true){
					treeHTML += '<th>check</th>';
				}
				for (var i = 0; i < coviCtrl.treeTableConfig.cols.length; i++) {
					var col = coviCtrl.treeTableConfig.cols[i];
					treeHTML += '<th>' + col.colName + '</th>';
				}
				if(coviCtrl.treeTableConfig.useControl != ''){
					treeHTML += '<th>'+Common.getDic("lbl_action")+'</th>';
				}
				treeHTML += '</tr>';
				treeHTML += '</thead>';
				treeHTML += '<tbody>';
				
				//rendering
				for (var i = 0; i < dataList.length; i++) {
					var sortPath = dataList[i][coviCtrl.treeTableConfig.sortPathKey];
					if(sortPath != null && sortPath != ''){
						treeHTML += coviCtrl.makeRowForTreeTable(dataList[i]);
					}
				}
				
				treeHTML += '</tbody>';
				treeHTML += '</table>';
				
				$('#' + coviCtrl.treeTableConfig.target).append(treeHTML);
				
				$('#treetable_' + coviCtrl.treeTableConfig.target).treetable({ expandable: true });

				// Highlight selected row
				$('#treetable_' + coviCtrl.treeTableConfig.target + ' tbody').on('mousedown', 'tr', function() {
					$('.selected').not(this).removeClass('selected');
					//$(this).toggleClass('selected');
					$(this).addClass('selected');
				});
				
				// 더블클릭
				$('#treetable_' + coviCtrl.treeTableConfig.target + ' tbody tr td').not('[data-event-bind=N]').on('dblclick', function() {
					var $row = $(this);
					var ttId = $row.attr('data-tt-id');
					var menuId = $row.attr('data-menuid');
					
					//method 호출
					if(coviCtrl.treeTableConfig.doubleClicked != null && coviCtrl.treeTableConfig.doubleClicked != ''){
						if(window[coviCtrl.treeTableConfig.doubleClicked] != undefined){
							window[coviCtrl.treeTableConfig.doubleClicked](menuId, ttId);
						} else if(parent[coviCtrl.treeTableConfig.doubleClicked] != undefined){
							parent[coviCtrl.treeTableConfig.doubleClicked](menuId, ttId);
						} else if(opener[coviCtrl.treeTableConfig.doubleClicked] != undefined){
							opener[coviCtrl.treeTableConfig.doubleClicked](menuId, ttId);
						}	
					}
				});
				
				// 싱글클릭
				$('#treetable_' + coviCtrl.treeTableConfig.target + ' tbody tr td').not('[data-event-bind=N]').find('span:last-child').on('click', function() {
					var $row = $(this).closest('tr');
					var ttId = $row.attr('data-tt-id');
					var menuId = $row.attr('data-menuid');					
					
					//method 호출
					if(coviCtrl.treeTableConfig.clicked != null && coviCtrl.treeTableConfig.clicked != ''){
						if(window[coviCtrl.treeTableConfig.clicked] != undefined){
							window[coviCtrl.treeTableConfig.clicked](menuId, ttId);
						} else if(parent[coviCtrl.treeTableConfig.clicked] != undefined){
							parent[coviCtrl.treeTableConfig.clicked](menuId, ttId);
						} else if(opener[coviCtrl.treeTableConfig.clicked] != undefined){
							opener[coviCtrl.treeTableConfig.clicked](menuId, ttId);
						}	
					}
				});
				
				coviCtrl.makeDraggable();
			},
			makeDraggable : function(){
				if(coviCtrl.treeTableConfig.drag == 'true' || coviCtrl.treeTableConfig.drag == true){
					//file Drag & Drop Example Code
					/*$('#treetable_' + coviCtrl.treeTableConfig.target + ' .file, #treetable_' + coviCtrl.treeTableConfig.target + ' .folder').draggable({
					  helper: "clone",
					  opacity: .75,
					  refreshPositions: true,
					  revert: "invalid",
					  revertDuration: 300,
					  scroll: true
					});
					 */
					$('#treetable_' + coviCtrl.treeTableConfig.target + ' .folder').each(function() {//폴더 list 그리기					
					  $(this).parents('#treetable_' + coviCtrl.treeTableConfig.target + ' tr').droppable({
					    accept: ".file, .folder",
					    drop: function(e, ui) {
					    	var droppedEl = ui.draggable.parents("tr");
					    	var $trs = droppedEl.parent().children(); 					    	
					    	if(droppedEl.data("ttId") != $(this).data("ttId")){
					    		//tt-id, tt-parent-id, sortpath, sortkey 처리
						      	//움직이는 대상만 데이터 처리
						      	var updatedRow = coviCtrl.updateDroppedEL(coviCtrl.sliceRowsForDrop(coviCtrl.treeTableConfig.target, droppedEl.index(), droppedEl, $trs), $(this));
						      	//method 호출
						      	if(coviCtrl.treeTableConfig.dropped != null && coviCtrl.treeTableConfig.dropped != ''){
									if(window[coviCtrl.treeTableConfig.dropped] != undefined){
										window[coviCtrl.treeTableConfig.dropped](updatedRow);
									} else if(parent[coviCtrl.treeTableConfig.dropped] != undefined){
										parent[coviCtrl.treeTableConfig.dropped](updatedRow);
									} else if(opener[coviCtrl.treeTableConfig.dropped] != undefined){
										opener[coviCtrl.treeTableConfig.dropped](updatedRow);
									}	
								}
								
								//move
						      	//droppedEL은 움직이는 대상, 
						      	//$(this).data("ttId")는 떨어뜨릴 곳
						      	$('#treetable_' + coviCtrl.treeTableConfig.target).treetable("move", droppedEl.data("ttId"), $(this).data("ttId"));
						      	//indenter 처리
						      	//child가 존재하지 않는 경우 a tag remove, padding-left:0px
					    	}
					    },
					    hoverClass: "accept",
					    over: function(e, ui) {
							var droppedEl = ui.draggable.parents("tr");
							if(this != droppedEl[0] && !$(this).is(".expanded")) {
								$('#treetable_' + coviCtrl.treeTableConfig.target).treetable("expandNode", $(this).data("ttId"));
							}
							
					    }
					  });
					});
				}
			},
			makeRowForTreeTable : function(dataObj){
				var option = coviCtrl.treeTableConfig;
				var html = '';
				
				var sortPath = dataObj[option.sortPathKey].slice(0, -1).split(';').join('-');
				var splittedSortPath = sortPath.split('-');
				var ttId = '';
				var ttParentId = '';
				
				if(splittedSortPath.length == 1){
					ttId = sortPath;
				} else {
					ttId = sortPath;
					var lastIdx = sortPath.lastIndexOf("-");
					ttParentId = sortPath.substring(0, lastIdx);
				}
				
				html += '<tr data-tt-id="' + ttId + '" ';
				for (var i = 0; i < option.dataAttrs.length; i++) {
					var dataAttr = option.dataAttrs[i];
					if(dataObj[dataAttr].length > 0){
						html += 'data-' + dataAttr + '="' + dataObj[dataAttr] + '" ';	
					}
				}
				if(ttParentId != ''){
					html += 'data-tt-parent-id="' + ttParentId + '" ';	
				}
				html += '>';
				
				if(option.checkBox == 'true' || option.checkBox == true){
					html += '	<td><input type="checkbox" name="treetable_chk_" value=""></td>';
				}
				for (var i = 0; i < option.cols.length; i++) {
					var col = option.cols[i];
					var formatter = col.formatter;
					
					var datastr = formatter != undefined ? formatter.call(dataObj) : dataObj[col.colKey];
					
					if(i == 0){
						html += '	<td class="left"'+((col.eventBind == "false") ? ' data-event-bind="N"' : '')+'><span class="folder" name="' + col.colKey + '">' + datastr + '</span></td>';	
					} else {
						html += '	<td'+((col.eventBind == "false") ? ' data-event-bind="N"' : '')+'><div class="bodyNode bodyTdText"><span name="' + col.colKey + '">' + datastr + '</span></div></td>';	
					}
				}
				//control
				html += '	<td><div class="btnActionWrap">';
				if(option.useControl.toLowerCase().indexOf('up') > -1){
					html += '<a href="javascript:;" class="btnTypeDefault btnMoveUp" onclick="coviCtrl.moveUpTreeTable(\'' + option.target + '\',this);return false;">'+Common.getDic("lbl_apv_up")+'</a>';
				}
				if(option.useControl.toLowerCase().indexOf('down') > -1){
					html += '<a href="javascript:;" class="btnTypeDefault btnMoveDown" onclick="coviCtrl.moveDownTreeTable(\'' + option.target + '\',this);return false;">'+Common.getDic("lbl_apv_down")+'</a>';
				}
				if(option.useControl.toLowerCase().indexOf('add') > -1){
					html += '<a href="javascript:;" class="btnTypeDefault btnPlusAdd" onclick="coviCtrl.addTreeTable(\'' + option.target + '\',this);return false;">'+Common.getDic("btn_apv_Person")+'</a>';
				}
				if(option.useControl.toLowerCase().indexOf('remove') > -1){
					html += '<a href="javascript:;" class="btnTypeDefault btnSaRemove" onclick="coviCtrl.removeTreeTable(\'' + option.target + '\',this);return false;">'+Common.getDic("lbl_delete")+'</a>';
				}
				if(option.useControl.toLowerCase().indexOf('move') > -1){
					html += '<a href="javascript:;" class="btnTypeDefault btnMove" onclick="coviCtrl.moveTreeTable(\'' + option.target + '\',this);return false;">'+Common.getDic("lbl_Move")+'</a>';
				}
				if(option.useControl.toLowerCase().indexOf('export') > -1){
					html += '<a href="javascript:;" class="btnTypeDefault"  onclick="coviCtrl.exportTreeTable(\'' + option.target + '\',this);return false;">'+Common.getDic("btn_apv_export")+'</a>';
				}
				
				html += '	</div></td>';
				
				html += '</tr>';
				
				return html;
			},
			treeTableLoadBranch : function(ttId, rows){
				var node;
				if(ttId != null){
					node = $('#treetable_' + coviCtrl.treeTableConfig.target).treetable('node', ttId);	
				}
				
				$('#treetable_' + coviCtrl.treeTableConfig.target).treetable('loadBranch', node, rows);
			},
			treeTableExpandAll : function(target){
				$('#treetable_' + target).treetable('expandAll');
			},
			treeTableCollapseAll : function(target){
				$('#treetable_' + target).treetable('collapseAll');
			},
			moveUpTreeTable : function(target, elm){
				var $row = $(elm).parents('tr:first');
				var ttId = $row.attr('data-tt-id');
				var splittedId = ttId.split('-');
				var ttPId = $row.attr('data-tt-parent-id');
				//slice
				var $rows = coviCtrl.sliceRows(target, $row.index() + 1, $row);
				//이전행은 같은 레벨이면서 같은 parent
				var $prevRow;
				$row.prevAll('tr').each(function(){
					if(splittedId.length == 1){
						//parent는 undefined
						if($(this).attr('data-tt-id').split('-').length == 1){
							$prevRow = $(this);
							return false;	
						}
					} else {
						if($(this).attr('data-tt-id').split('-').length == splittedId.length 
								&& ttPId == $(this).attr('data-tt-parent-id')){
							$prevRow = $(this);
							return false;	
						}
					}
				});
				
				if( $prevRow != undefined){
					var row_sortkey  = $row.attr('data-sortkey');
					var prev_row_ttId = $prevRow.attr('data-tt-id');
					var prev_row_sortkey = $prevRow.attr('data-sortkey');
					
					//prev node와 자식들의 data-tt-id, data-tt-parent-id, data-tt-sortpath 처리
					var $prevRows = coviCtrl.sliceRows(target, $prevRow.index() + 1, $prevRow);
					var prevUpdatedRows = coviCtrl.updateRows($prevRows, ttId, row_sortkey);
					
					//자신의 node와 자식들의 data-tt-id, data-tt-parent-id, data-tt-sortpath 처리
					var updatedRows = coviCtrl.updateRows($rows, prev_row_ttId, prev_row_sortkey);
					
					//render
					$rows.insertBefore($prevRow);
					
					var mergedUpdatedRows = $.merge(prevUpdatedRows, updatedRows);
					//method 호출
					if(coviCtrl.treeTableConfig.upClicked != null && coviCtrl.treeTableConfig.upClicked != ''){
						if(window[coviCtrl.treeTableConfig.upClicked] != undefined){
							window[coviCtrl.treeTableConfig.upClicked](mergedUpdatedRows);
						} else if(parent[coviCtrl.treeTableConfig.upClicked] != undefined){
							parent[coviCtrl.treeTableConfig.upClicked](mergedUpdatedRows);
						} else if(opener[coviCtrl.treeTableConfig.upClicked] != undefined){
							opener[coviCtrl.treeTableConfig.upClicked](mergedUpdatedRows);
						}
					}
				}
				
			},//end moveUp
			moveDownTreeTable : function(target, elm){
				var $row = $(elm).parents('tr:first');
				var ttId = $row.attr('data-tt-id');
				var splittedId = ttId.split('-');
				var ttPId = $row.attr('data-tt-parent-id');
				//slice
				var $rows = coviCtrl.sliceRows(target, $row.index() + 1, $row);
				//이전행은 같은 레벨이면서 같은 parent
				var $nextRow;
				$row.nextAll('tr').each(function(){
					if(splittedId.length == 1){
						//parent는 undefined
						if($(this).attr('data-tt-id').split('-').length == 1){
							$nextRow = $(this);
							return false;	
						}
					} else {
						if($(this).attr('data-tt-id').split('-').length == splittedId.length 
								&& ttPId == $(this).attr('data-tt-parent-id')){
							$nextRow = $(this);
							return false;	
						}
					}
				});
				
				if( $nextRow != undefined){
					var row_sortkey  = $row.attr('data-sortkey');
					var next_row_ttId = $nextRow.attr('data-tt-id');
					var next_row_sortkey = $nextRow.attr('data-sortkey');
					
					//next node와 자식들의 data-tt-id, data-tt-parent-id, data-tt-sortpath 처리
					var $nextRows = coviCtrl.sliceRows(target, $nextRow.index() + 1, $nextRow);
					var nextUpdatedRows = coviCtrl.updateRows($nextRows, ttId, row_sortkey);
					
					//자신의 node와 자식들의 data-tt-id, data-tt-parent-id, data-tt-sortpath 처리
					var updatedRows = coviCtrl.updateRows($rows, next_row_ttId, next_row_sortkey);
					
					//render
					$rows.insertAfter($nextRows.last());
					
					var mergedUpdatedRows = $.merge(nextUpdatedRows, updatedRows);
					//method 호출
					if(coviCtrl.treeTableConfig.downClicked != null && coviCtrl.treeTableConfig.downClicked != ''){
						if(window[coviCtrl.treeTableConfig.downClicked] != undefined){
							window[coviCtrl.treeTableConfig.downClicked](mergedUpdatedRows);
						} else if(parent[coviCtrl.treeTableConfig.downClicked] != undefined){
							parent[coviCtrl.treeTableConfig.downClicked](mergedUpdatedRows);
						} else if(opener[coviCtrl.treeTableConfig.downClicked] != undefined){
							opener[coviCtrl.treeTableConfig.downClicked](mergedUpdatedRows);
						}
					}
				}
				
			},//moveDown
			addTreeTable : function(target, elm){//폴더추가
				var $row = $(elm).parents('tr:first');
				var ttId = $row.attr('data-tt-id');
				var menuId = $row.attr('data-menuid');
				
				//method 호출
				if(coviCtrl.treeTableConfig.addClicked != null && coviCtrl.treeTableConfig.addClicked != ''){
					if(window[coviCtrl.treeTableConfig.addClicked] != undefined){
						window[coviCtrl.treeTableConfig.addClicked](menuId, ttId);
					} else if(parent[coviCtrl.treeTableConfig.addClicked] != undefined){
						parent[coviCtrl.treeTableConfig.addClicked](menuId, ttId);
					} else if(opener[coviCtrl.treeTableConfig.addClicked] != undefined){
						opener[coviCtrl.treeTableConfig.addClicked](menuId, ttId);
					}
				}
				
			},//end Add
			removeTreeTable : function(target, elm){//폴더삭제
				var $row = $(elm).parents('tr:first');
				var ttId = $row.attr('data-tt-id');
				
				//method 호출
				if(coviCtrl.treeTableConfig.removeClicked != null && coviCtrl.treeTableConfig.removeClicked != ''){
					if(window[coviCtrl.treeTableConfig.removeClicked] != undefined){
						window[coviCtrl.treeTableConfig.removeClicked](ttId);
					} else if(parent[coviCtrl.treeTableConfig.removeClicked] != undefined){
						parent[coviCtrl.treeTableConfig.removeClicked](ttId);
					} else if(opener[coviCtrl.treeTableConfig.removeClicked] != undefined){
						opener[coviCtrl.treeTableConfig.removeClicked](ttId);
					}
				}
			},//end Romve
			moveTreeTable : function(target, elm){//file Move 버튼 이벤트 
				var $row = $(elm).parents('tr:first');
				/*var sortKey = $row.attr('data-sortkey');*/
				var menuId = $row.find("span[name='MenuID']").html();
				var sortPath = $row.attr('data-sortpath');
			
				//method 호출
				if(coviCtrl.treeTableConfig.moveClicked != null && coviCtrl.treeTableConfig.moveClicked != ''){
					if(window[coviCtrl.treeTableConfig.moveClicked] != undefined){
						window[coviCtrl.treeTableConfig.moveClicked](menuId, sortPath);
					} else if(parent[coviCtrl.treeTableConfig.moveClicked] != undefined){
						parent[coviCtrl.treeTableConfig.moveClicked](menuId, sortPath);
					} else if(opener[coviCtrl.treeTableConfig.moveClicked] != undefined){
						opener[coviCtrl.treeTableConfig.moveClicked](menuId, sortPath);
					}
				}
			},
			exportTreeTable : function(target, elm){ // Export 버튼 이벤트 
				var $row = $(elm).parents('tr:first');
				/*var sortKey = $row.attr('data-sortkey');*/
				var menuId = $row.find("span[name='MenuID']").html();
				var sortPath = $row.attr('data-sortpath');
				
				//method 호출
				if(coviCtrl.treeTableConfig.exportClicked != null && coviCtrl.treeTableConfig.exportClicked != ''){
					if(window[coviCtrl.treeTableConfig.exportClicked] != undefined){
						window[coviCtrl.treeTableConfig.exportClicked](menuId, sortPath);
					} else if(parent[coviCtrl.treeTableConfig.exportClicked] != undefined){
						parent[coviCtrl.treeTableConfig.exportClicked](menuId, sortPath);
					} else if(opener[coviCtrl.treeTableConfig.exportClicked] != undefined){
						opener[coviCtrl.treeTableConfig.exportClicked](menuId, sortPath);
					}
				}
			},
			sliceRows : function(target, begin, rowElm){
				//slice row
				var last;
				var ttId = rowElm.attr('data-tt-id');
				rowElm.nextAll('tr').each(function(){
					var row_ttId = $(this).attr('data-tt-id');
					if(row_ttId.substring(0,ttId.length) != ttId){
						last = $(this).index() + 1;
						return false;
					}
				});
				
				var $rows;
				if(begin != last){
					$rows = $('#treetable_' + target + ' tr').slice(begin, last);	
				} else {
					$rows = rowElm;
				}
				
				return $rows;
			},
			sliceRowsForDrop : function(target, begin, rowElm, trAll){
				//slice row
				var last;
				var ttId = rowElm.attr('data-tt-id');
				var i = 0;
				trAll.each(function(){
					var row_ttId = $(this).attr('data-tt-id');
					if(i >= begin && row_ttId.substring(0,ttId.length) != ttId){
						last = i;
						return false;
					} else if(i == (trAll.length - 1)){
						last = i + 1;
						return false;
					}
					i++;
				});
				
				var $rows;
				if(last != undefined && begin != last){
					$rows = trAll.slice(begin, last);	
				} else {
					$rows = rowElm;
				}
				
				return $rows;
			},
			updateRows : function(rowElms, ttId, sortkey){
				var updatedRowArray = new Array();
				var lvl = ttId.split('-').length - 1;
				var start = lvl*16;
				var end = start + 14;
				var parsedId = ttId.split('-')[lvl];
				
				rowElms.each(function(){
					var updatedRow = new Object();
					//get
					var $row = $(this);
					var row_ttId = $row.attr('data-tt-id');
					var row_parent_ttId = $row.attr('data-tt-parent-id');
					var row_sortpath = $row.attr('data-sortpath');
					//replace
					var replaced_ttId = coviCtrl.replaceStringBetween(start, end, row_ttId, parsedId);
					$row.attr('data-tt-id', replaced_ttId);
					if(row_parent_ttId != undefined){
						var replaced_parent_ttId = coviCtrl.replaceStringBetween(start, end, row_parent_ttId, '');
						$row.attr('data-tt-parent-id', replaced_parent_ttId);
					}
					var replaced_sortpath = coviCtrl.replaceStringBetween(start, end, row_sortpath, parsedId);
					$row.attr('data-sortpath', replaced_sortpath);
					if(row_ttId.split('-').length == ttId.split('-').length){
						$row.attr('data-sortkey', sortkey);
					}
					
					//update될 row 정보 추출
					updatedRow.menuid = $row.attr('data-menuid');
					updatedRow.memberof = $row.attr('data-memberof');
					updatedRow.sortkey = $row.attr('data-sortkey');
					updatedRow.sortpath = $row.attr('data-sortpath');
					updatedRowArray.push(updatedRow);
				});
				
				return updatedRowArray;
			},
			updateDroppedEL : function(droppedElm, targetElm){
				//targetElm은 부모 el이 됨
				//targetElm의 맨 마지막 자식 select
				var parent_ttId = targetElm.attr('data-tt-id');
				var $last;
				if(parent_ttId != undefined && parent_ttId != ''){
					$last = targetElm.nextAll('tr[data-tt-parent-id=' + parent_ttId  + ']').last();
				}
				
			
				var parent_menuid = targetElm.attr('data-menuid');
				var parent_sortpath = targetElm.attr('data-sortpath');
				var sortIdx;
				if($last == undefined || $last.length == 0){
					sortIdx = 0;
				} else {
					sortIdx = Number($last.attr('data-sortkey')) + 1;
				}
				
				var updatedRowArray = new Array();
				var firstRow_ttId;
				//var firstRow_parent_ttId;
				var firstRow_sortpath;
				var cnt = 0;
				droppedElm.each(function(){
					var updatedRow = new Object();
					cnt++;
					var $row = $(this);
					
					//첫번째 node update
					var padded_ttId = parent_ttId + '-' + coviCtrl.pad(sortIdx, 15);
					var padded_sortpath = parent_sortpath + coviCtrl.pad(sortIdx, 15)  + ';';
					
					if(cnt == 1){
						firstRow_ttId = $row.attr('data-tt-id');
						//firstRow_parent_ttId = $row.attr('data-tt-parent-id');
						firstRow_sortpath = $row.attr('data-sortpath');
						
						//sortkey
						$row.attr('data-sortkey', sortIdx);
						//parentObjectId
						//$row.attr('data-parentobjectid', $last.attr('data-parentobjectid'));
						//parentobjectType
						//$row.attr('data-parentobjecttype', $last.attr('data-parentobjecttype'));
						//memberOf
						$row.attr('data-memberof', parent_menuid);
						$row.attr('data-tt-parent-id', parent_ttId);
					}
					
					//자리수에 맞춰서 replace
					//tt-id
					$row.attr('data-tt-id', padded_ttId + coviCtrl.replaceStringBetween(0, firstRow_ttId.length - 1, $row.attr('data-tt-id'), ''));
					//tt-parent-id
					if(cnt > 1){
						$row.attr('data-tt-parent-id', padded_ttId + coviCtrl.replaceStringBetween(0, firstRow_ttId.length - 1, $row.attr('data-tt-parent-id'), ''));
					}
					//sortpath
					$row.attr('data-sortpath', padded_sortpath + coviCtrl.replaceStringBetween(0, firstRow_sortpath.length - 1, $row.attr('data-sortpath'), ''));
					
					//update될 row 정보 추출
					updatedRow.menuid = $row.attr('data-menuid');
					updatedRow.memberof = $row.attr('data-memberof');
					updatedRow.sortkey = $row.attr('data-sortkey');
					updatedRow.sortpath = $row.attr('data-sortpath');
					updatedRowArray.push(updatedRow);
				});
				
				return updatedRowArray;
			},
			replaceStringBetween : function(start, end, str, what){
				var _str = '' + str;
				return _str.substring(0, start) + what + _str.substring(end+1);
			},
			pad : function pad(n, width, z) {
				z = z || '0';
				n = n + '';
				return n.length >= width ? n : new Array(width - n.length + 1).join(z) + n;
			},
			
			//pType: Simple, List ... 
			//pUserCode: 조회를 원하는 사용자 ID 
			formatUserContext: function( pType, pUserName, pUserCode, pMailAddress){
				//flowerPopup Class명으로 Context Menu 호출 이벤트가 바인드 되어 있음
				var divMenu = $('<div class="flowerPopup" onclick="coviCtrl.setFlowerName(this)" />').attr({'data-user-code':pUserCode, 'data-user-mail': pMailAddress});
				var anchorUserName = $('<a class="btnFlowerName" />');
				
				//클래스 및  태그 구조가 다를 경우
				if(pType == "Simple"){
					anchorUserName.text(pUserName);
				} else {
					anchorUserName.append($('<span class="fcStyle"/>').text(pUserName));
				}
				
				return divMenu.append(anchorUserName).prop('outerHTML');
			},
			
			goProfilePopup: function(pUserCode){//프로필
				if(parent.name == "Iframe"){
					Common.open("","MyInfo",Common.getDic("lbl_UserProfile"),"/covicore/control/callMyInfo.do?userID="+pUserCode,"610px","500px","iframe",true,null,null,true);
				}else{
					parent.Common.open("","MyInfo",Common.getDic("lbl_UserProfile"),"/covicore/control/callMyInfo.do?userID="+pUserCode,"610px","500px","iframe",true,null,null,true);
				}
				coviCtrl.closeInfoContext();
			},
			closeInfoContext: function(){
				$("#flowerMenu").attr('class','flowerMenuList');
			},
			
			ctxSendMail: function(pUserCode){
				alert("메일보내기 : " + pUserCode);
			},
			ctxFollowing: function(pUserCode){
				alert("팔로잉 : " + pUserCode);
			},
			ctxInviteChat: function(pUserCode){
				alert("대화하기 : " + pUserCode);
			},
			addFavoriteContact: function(pUserCode){
				if(pUserCode == Common.getSession('USERID')){
					Common.Warning(Common.getDic("msg_cannot_add_oneself"));	// 자기 자신은 즐겨 찾는 연락처에 추가할 수 없습니다.
				} else {
					//TODO: sys_sensing_org에는 UR, GR을 대상으로 추가...GR 연락처 어디서?
					Common.Confirm(Common.getDic("msg_add_favoritecontact"), 'Confirmation Dialog', function (result) { // 자주 쓰는 연락처에 추가 하시겠습니까?
			            if (result) {
			            	$.ajax({
			        	    	type:"POST",
			        	    	url:"/covicore/contact/create.do",
			        	    	data:{
			        	    		"selectedCode": pUserCode
			        	    	},
			        	    	success:function(data){
			        	    		if(data.status=='SUCCESS'){			//추가 성공 혹은 중복 등록 경고
			        	    			Common.Inform(data.message);
			        	    			coviCtrl.getContactNumberList();//추가 이후 재조회
			        	    		}else{
			        	    			Common.Warning(Common.getDic('msg_apv_030'));//오류가 발생헸습니다.
			        	    		}
			        	    	},
			        	    	error:function(response, status, error){
			        	    	     CFN_ErrorAjax("/covicore/contact/create.do", response, status, error);
			        	    	}
			        	    });
			            }
			        });
				}
			},
			deleteFavoriteContact: function(pSelectedType, pSelectedCode){
				//TODO: sys_sensing_org에는 UR, GR을 대상으로 추가...GR 연락처 어디서?
				Common.Confirm(Common.getDic("msg_delete_favoritecontact"), Common.getDic('lbl_Confirm'), function (result) { // 자주 쓰는 연락처에서 삭제 하시겠습니까?
		            if (result) {
		            	$.ajax({
		        	    	type:"POST",
		        	    	url:"/covicore/contact/delete.do",
		        	    	data:{
		        	    		"selectedType": pSelectedType
		        	    		,"selectedCode": pSelectedCode
		        	    	},
		        	    	success:function(data){
		        	    		if(data.status=='SUCCESS'){			//추가 성공 혹은 중복 등록 경고
		        	    			Common.Warning(data.message);
		        	    			coviCtrl.getContactNumberList();//추가 이후 재조회
		        	    		}else{
		        	    			Common.Warning(Common.getDic('msg_apv_030'));//오류가 발생헸습니다.
		        	    		}
		        	    	},
		        	    	error:function(response, status, error){
		        	    	     CFN_ErrorAjax("/covicore/contact/delete.do", response, status, error);
		        	    	}
		        	    });
		            }
		        });
			},
			clickFavoriteContactMail: function(displayName, mailAddress){
				// TODO CP 메일 작성창 연결 페이지 만들어지면 연결되도록 수정
				/*var popupId = "MailListSentTo";
				
				Common.open("", popupId, "메일 작성",
	                        "/mail/bizcard/goMailWritePopup.do?"
	                        + "callBackFunc=mailWritePopupCallback"
	                        + "&callMenu="+"MailList"
	                        + "&userMail="+ Common.getSession("UR_Mail")
	                        + "&inputUserId="+ (Common.getSession("DN_Code")+"_"+Common.getSession("UR_Code"))
	                        + "&toUserMail="+ mailAddress
	                        + "&toUserName="+ displayName
	                        + "&isInbox="+"Y",
	                        //+"&secureMailPw="+secureMailPw
	                        "1000px", "800px", "iframe", true, null, null, true);*/
			},
			/**
			 * 여러개 검색값 INSERT 할 경우, SearchWord를 배열로 전송
			 * @param searchWord
			 * @param system
			 * @param domainID
			 * @param onCompleted
			 */
			insertSearchData: function(searchWord, system, domainID, onCompleted){
				if(domainID == undefined || domainID == "")
					domainID = Common.getSession("DN_ID");
				
				var searchWordTemp = "";
				if(typeof searchWord == "object"){
					for(var i=0; i<searchWord.length; i++)
						searchWordTemp += searchWord[i] + "¶";
				}else{
					searchWordTemp = searchWord;
				}
				
				$.ajax({
					url : "/covicore/searchWord/insertSearchData.do",
					type:"post",
					data : {
						"searchWord" : searchWordTemp,
						"system" : system,
						"domainID" : domainID
					},
					success : function(data){
						if(data.status == "SUCCESS"){
							if(onCompleted != undefined && onCompleted != null && onCompleted != ''){
								if(window[onCompleted] != undefined){
									window[onCompleted](this);
								} else if(parent[onCompleted] != undefined){
									parent[onCompleted](this);
								} else if(opener[onCompleted] != undefined){
									opener[onCompleted](this);
								}
							}
						}else{
							Common.Error("<spring:message code='Cache.msg_apv_005'/> : "+data.message);
						}
					},
					error:function (error){
						CFN_ErrorAjax("/covicore/searchWord/insertSearchData.do", response, status, error);
					}
				});
			},			
			setFlowerName: function(target){
			//이벤트 호출시 flowerPopup내부 Context Menu 태그 생성
				if($(target).find('.flowerMenuList').size() == 0){ 
					var pUserCode = $(target).attr('data-user-code');
					var pUserMail = $(target).attr('data-user-mail');
					
					var ulMenuList = $('<ul class="flowerMenuList" id="flowerMenu"/>');
					if(!$(target).hasClass("flowerPopup")){
						ulMenuList.css({"list-style":"none", "padding":"0px", "margin-top":"7px"});
					}
					
					//Profile
					var anchorProfile = $('<a onclick="javascript:coviCtrl.goProfilePopup(\''+pUserCode+'\');return false;"/>').text(Common.getDic("lbl_UserProfile"));
					ulMenuList.append($('<li class="flowerProfile"/>').append(anchorProfile));
					
					//Talk
					if(Common.getGlobalProperties("lync.chat.used") == "Y" && pUserMail != undefined && pUserMail != ""){
						var anchorTalk = $('<a href="sip:' + pUserMail + '"/>').text(Common.getDic("lbl_Chat"));
						ulMenuList.append($('<li class="flowerTalk"/>').append(anchorTalk));
					}
					
					//Contact
					var anchorAddr = $('<a onclick="javascript:coviCtrl.addFavoriteContact(\''+pUserCode+'\');return false;"/>').text(Common.getDic("lbl_AddContact"));
					ulMenuList.append($('<li class="flowerAddr"/>').append(anchorAddr));
					$(target).append(ulMenuList);
		   		} 
				sibNode = $(target).find('.flowerMenuList');
				
				if(sibNode.hasClass('active')){
					sibNode.removeClass('active');
				}else {
					$('.flowerMenuList').removeClass('active');
					sibNode.addClass('active');
				}
			}
			
	};//---------------------------
	
	window.coviCtrl = coviCtrl;
	
	var ctrlMethods = {
		test : function(){
			return this.each(function(){
				$(this).val("call test Method !!");
			});
		},
		//select option 추가
		//topOptionValue : 셀렉트 박스 내용, topOptionKey : 선택한 Key값 ( ex : <option value="topOptionValue"> topOptionText </option> )
		setSelectOption : function( url , param, topOptionText, topOptionValue, selId ){
			return this.each(function(){
				var selectElement = $(this);
				//기존옵션제거
				if (selectElement.prop('tagName')=='SELECT' ) {
					$(this).find("option").remove();
					//ajax로 옵션 데이터 가져와서 셀렉트에 옵션추가 
					$.ajax({
						type:"POST",
				        async : false,
				        url : url,
				        data : param,
				        success: function(data){
			        		var option;
							//option 추가
							if(data.list !== undefined){
								if(topOptionText !== undefined && topOptionText !== "" ){
									option = $('<option/>').append(topOptionText).val(topOptionValue);
									selectElement.append(option);
								}
								var groupValue = "";
								var groupOption;
								$.each(data.list, function(idx, optionData){
									//SelectBox 내부 Option Group 확인
									if(optionData.groupText !== undefined && optionData.groupText !== ""){
										if(groupValue != optionData.groupValue){
											groupValue = optionData.groupValue;	//compare variable
											groupOption = $('<optGroup/>');	//optGroup Element생성
											groupOption.attr('label', optionData.groupText);		//그룹별 이름 
										}
										option = $('<option/>').append(optionData.optionText).val(optionData.optionValue);
										groupOption.append(option);
						        		selectElement.append(groupOption);
									} else if(optionData.multiOptionText !== undefined && optionData.multiOptionText !== ""){
										var lang = Common.getSession("lang");
										option = $('<option/>').append(CFN_GetDicInfo(optionData.multiOptionText, lang)).val(optionData.optionValue);
										selectElement.append(option);
									} else {
										option = $('<option/>').append(optionData.optionText).val(optionData.optionValue);
										if (selId==optionData.optionValue) {
											option.attr("selected", "selected");
										}
										selectElement.append(option);
									}
					     		});
							}else{
								option = $('<option/>').append("NO DATA").val("none_error_data");
								selectElement.append(option);
							}
						},
						error:function(response, status, error){
							CFN_ErrorAjax(url, response, status, error);
			       		}
				 	});
				}
			});
		},
		
		setDateInterval : function( pStartElement, pEndElement, pIntervalParam, pIntervalInit){
			return this.each(function(){	
				var selectElement = $(this);
				if (selectElement.prop('tagName')=='SELECT' ) {
					$(this).find("option").remove();
					if(pIntervalParam != undefined && pIntervalParam != ""){
						//TODO: 기간 설정 관련 Day, Week, Month, Year 동적으로 처리 예정
					} else { 
						var lang = Common.getSession("lang");
						selectElement.append(new Option(CFN_GetDicInfo(coviCtrl.dictionary.select, lang), ''));
						selectElement.append(new Option('1'+CFN_GetDicInfo(coviCtrl.dictionary.week, lang), '1W'));
						selectElement.append(new Option('2'+CFN_GetDicInfo(coviCtrl.dictionary.week, lang), '2W'));
						selectElement.append(new Option('1'+CFN_GetDicInfo(coviCtrl.dictionary.month, lang), '1M'));
						selectElement.append(new Option('1'+CFN_GetDicInfo(coviCtrl.dictionary.year, lang), '1Y'));
					}
					var startDate = pStartElement;	//시작일시
					var endDate = pEndElement;
					
					selectElement.on('change', function(){
						var changeTarget = "end"
						var intervalValue = parseInt($(this).val().split("")[0]);
						var intervalType = $(this).val().split("")[1];
						var sDate = null;
						var eDate = null;
						
						if (selectElement.val() == ''){
							startDate.val('');
							endDate.val('');
							return false;
						}
						
						if(pIntervalInit != undefined && pIntervalInit != "" ){
							if(pIntervalInit.changeTarget != undefined && pIntervalInit.changeTarget != ""){
								changeTarget = pIntervalInit.changeTarget;
							}
						}
						
						if(changeTarget == "start"){
							if(endDate.val() != "" && pEndElement != undefined){
								//separator를 별도로 구분하지 않고 yyyy.MM.dd format으로 처리
								eDate = new Date(endDate.val().substring(0,4)+"-"+endDate.val().substring(5,7)+"-"+endDate.val().substring(8,10));
							} else {
								eDate = new Date(CFN_GetLocalCurrentDate(_StandardServerDateFormat));
							}
							
							var sDate;
							if(intervalType == "D"){
								sDate = new Date(eDate.getFullYear(), eDate.getMonth(), eDate.getDate()-intervalValue);
							} else if(intervalType == "W"){
								sDate = new Date(eDate.getFullYear(), eDate.getMonth(), eDate.getDate()-(intervalValue*7));
							} else if(intervalType == "M"){
								sDate = new Date(eDate.getFullYear(), eDate.getMonth()-intervalValue, eDate.getDate());
							} else if(intervalType == "Y"){
								sDate = new Date(eDate.getFullYear()-intervalValue, eDate.getMonth(), eDate.getDate());
							} else {
								sDate = new Date(eDate.getFullYear(), eDate.getMonth(), eDate.getDate());
							}
						} else {
							if(startDate.val() != "" && pEndElement != undefined){
								//separator를 별도로 구분하지 않고 yyyy.MM.dd format으로 처리
								sDate = new Date(startDate.val().substring(0,4)+"-"+startDate.val().substring(5,7)+"-"+startDate.val().substring(8,10));
							} else {
								sDate = new Date(CFN_GetLocalCurrentDate(_StandardServerDateFormat));
							}
							
							var eDate;
							if(intervalType == "D"){
								eDate = new Date(sDate.getFullYear(), sDate.getMonth(), sDate.getDate()+intervalValue);
							} else if(intervalType == "W"){
								eDate = new Date(sDate.getFullYear(), sDate.getMonth(), sDate.getDate()+(intervalValue*7));
							} else if(intervalType == "M"){
								eDate = new Date(sDate.getFullYear(), sDate.getMonth()+intervalValue, sDate.getDate());
							} else if(intervalType == "Y"){
								eDate = new Date(sDate.getFullYear()+intervalValue, sDate.getMonth(), sDate.getDate());
							} else {
								eDate = new Date(sDate.getFullYear(), sDate.getMonth(), sDate.getDate());
							}
						}
						if(pEndElement != undefined){
							startDate.val(sDate.format('yyyy.MM.dd'));
							endDate.val(eDate.format('yyyy.MM.dd'));
						} else {
							startDate.val(eDate.format('yyyy.MM.dd'));
						}
					});
				}
				
				if(pIntervalInit != undefined && pIntervalInit != "" ){
					if(pIntervalInit.initVal != undefined && pIntervalInit.initVal != ""){
						$(this).val(pIntervalInit.initVal);
					}
				}
			});
		},
		
		//pIntervalParam: 60의 약수
		setTime : function( pIntervalParam ){
			if(pIntervalParam == undefined || pIntervalParam == ""){
				pIntervalParam = 1;
			}
			return this.each(function(){	
				var selectElement = $(this);
				if (selectElement.prop('tagName')=='SELECT' ) {
					$(this).find("option").remove();
					//배열 추가 
					for( var i=0; i < 24; i++ ){
						var h = "0" + i;
						var hour = h.substr( h.length -2, 2 );
						for( var j=0; j < 60; j=j+pIntervalParam ){
							var m = "0" + j;
							var option = String.format("{0}:{1}",  hour , m.substr( m.length -2, 2 )) ;
							selectElement.append(new Option(option, option));
						}
					}
					//23:59 59분 데이터를 넣기보다 다음달 00:00분으로 설정하는게 더 깔끔하지 않나
//					if(selectElement.last().val() != "23:59"){
//						selectElement.append(new Option("23:59", "23:59"));
//					}
				}
			});
		},
		
		goProfilePopup : function( pUserCode ){
			return this.click(function(){
				coviCtrl.goProfilePopup(pUserCode);
			}.bind(this));
		},
		
		setUserInfoContext: function(){//사용자 프로필.연락처 추 가		
			return this.each(function(){
				var pUserCode = $(this).attr('data-user-code');
				var pUserMail = $(this).attr('data-user-mail');
				
				var ulMenuList = $('<ul class="flowerMenuList" id="flowerMenu"/>');
				
				//Profile
				var anchorProfile = $('<a onclick="javascript:coviCtrl.goProfilePopup(\''+pUserCode+'\');return false;"/>').text(Common.getDic("lbl_UserProfile"));
				ulMenuList.append($('<li class="flowerProfile"/>').append(anchorProfile));
				/*
				//Mail
				var anchorMail = $('<a onclick="javascript:coviCtrl.ctxSendMail(\''+pUserCode+'\');return false;"/>').text('메일 보내기');
				ulMenuList.append($('<li class="flowerMail"/>').append(anchorMail));
				//Following
				var anchorFollowing = $('<a onclick="javascript:coviCtrl.ctxFollowing(\''+pUserCode+'\');return false;"/>').text('팔로잉');
				ulMenuList.append($('<li class="flowerFollowing"/>').append(anchorFollowing));
				*/
				
				//Talk
				if(Common.getGlobalProperties("lync.chat.used") == "Y" && pUserMail != undefined && pUserMail != ""){
					var anchorTalk = $('<a href="sip:' + pUserMail + '"/>').text(Common.getDic("lbl_Chat"));
					ulMenuList.append($('<li class="flowerTalk"/>').append(anchorTalk));
				}
				
				//Contact
				var anchorAddr = $('<a onclick="javascript:coviCtrl.addFavoriteContact(\''+pUserCode+'\');return false;"/>').text(Common.getDic("lbl_AddContact"));
				ulMenuList.append($('<li class="flowerAddr"/>').append(anchorAddr));
				$(this).append(ulMenuList);
				
			});
			
			
		}
	};
	
	
	$.fn.coviCtrl = function( method ){
		if ( ctrlMethods[method] ) {
		      return ctrlMethods[method].apply( this, Array.prototype.slice.call( arguments, 1 ));
		    } else if ( typeof method === 'object' || ! method ) {
	      return ctrlMethods.init.apply( this, arguments );
	    } else {
	      $.error( 'Method ' +  method + ' does not exist on covision.control.js' );
		}    
	};
	
	$.widget("ui.autocomplete", $.ui.autocomplete, {
	    options : $.extend({}, this.options, {
	        multiselect: false,
	        useEnter : false,
	        callType : "",
	        useDuplication : false,
	        callBackFunction: ""
	    }),
	    _create: function(){
	        this._super();

	        var self = this,
	            o = self.options;

	        if (o.multiselect) {
	            self.selectedItems = {};           
	            self.multiselect = $("<div></div>")
	                .addClass("ui-autocomplete-multiselect ui-state-default ui-widget")
	                //.css("width", self.element.width())
	                .css("width", 'calc(100% - 266px)')
	                .css("overflow", 'auto')
	                .css("max-height", '50px')
	                .insertBefore(self.element)
	                .append(self.element)
	                .bind("click.autocomplete", function(){
	                    self.element.focus();
	                });
	            
	            /*
	            var fontSize = parseInt(self.element.css("fontSize"), 10);
	            
	            function autoSize(e){
	                var $this = $(this);
	                $this.width(1).width(this.scrollWidth+fontSize-1);
	            };
				*/
	            
	            var kc = $.ui.keyCode;
	            self.element.bind({
	                "keydown.autocomplete": function(e, ui){
	                	if ((this.value === "") && (e.keyCode == kc.BACKSPACE)) {
	                        var prev = self.element.prev();
	                        delete self.selectedItems[prev.attr("data-value")];
	                        prev.remove();
	                    }
                        else if(o.useEnter && self.term !== '' && e.keyCode == kc.ENTER){
                            if(e.target.value === '') return false;				// 이벤트가 발생한 요소의 값이 없으면 처리하지 않음.
                            if(e.target.value != self.term) return false;		// 이벤트 처리 시점과 발생 시점의 값이 서로 다르면 처리하지 않음.
                            if(! o.useDuplication){								// 중복입력이 불허인 경우, 같은 값이 있으면 메시지 출력하고 데이터는 처리하지 않음.
                                if (self.element.parent().find(".ui-autocomplete-multiselect-item[data-value='"+ e.target.value+"']").length > 0) {
                                    Common.Warning(Common.getDic("ACC_msg_existItem"));
                                    e.target.value = '';
                                    return;
                                }
                            }
	                    	
	                    	//MAIL에서 사용되는 자동완성일경우
	                    	var inputData = {"label":self.term, "value":self.term};
	                    	
	                    	if(o.callType == "MAIL"){
	                    		var regExp = /^[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*@[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*.[a-zA-Z]{2,3}$/i;
	                    		//Enter로 등록 후 Enter를 계속 누르면 이전에 들어갔던 데이터가 계속 들어가는 현상 방지 
	                    		if(self.selectedItems[self.term] != null && self.selectedItems[self.term].length != 0){
	                    			return;
	                    		}
	                    		
	                    		if(self.term.match(regExp) == null){
	                    			return;
	                    		}
	                    		
	                    		inputData = {
									"UserCode": self.term, 
									"UserName": self.term, 
									"MailAddress": self.term, 
									"label": self.term, 
									"value": self.term
								};
		                        delete self.selectedItems[self.term];
	                    	}
	                    	
	                    	$("<div></div>")
		                    .addClass("ui-autocomplete-multiselect-item")
		                    //.attr("data-json", JSON.stringify({"label":self.term, "value":self.term}))
		                    .attr("data-json", JSON.stringify(inputData))
		                    .attr("data-value", self.term)
		                    .text(self.term)
		                    .append(
		                        $("<span></span>")
		                            .addClass("ui-icon ui-icon-close")
		                            .click(function(){
		                                var item = $(this).parent();
		                                delete self.selectedItems[item.text()];
		                                item.remove();
		                            })
		                    )
		                    .insertBefore(self.element);
		                
	                    	self.selectedItems[self.term] = self.term;
	                    	self._value("");
	                    	self._close();
	                    }
	                }
	            	/*
	            	,
	                "focus.autocomplete": function(e){
	                	e.preventDefault();
	                    //self.multiselect.toggleClass("ui-state-active");
	                },
	                "blur.autocomplete": function(e){
	                	e.preventDefault();
	                	//self.multiselect.toggleClass("ui-state-active");
	                },
	                "keypress.autocomplete change.autocomplete focus.autocomplete blur.autocomplete": autoSize
	                */
	            }).trigger("change");

	            o.focus = function(e, ui) {
	            	return false;
	            }
	            
	            o.select = function(e, ui) {
	            	if(! o.useDuplication){
		            	if (self.element.parent().find(".ui-autocomplete-multiselect-item[data-value='"+ ui.item.value+"']").length > 0) {
		    				Common.Warning(Common.getDic("ACC_msg_existItem"));
		    				ui.item.value = '';
		    				return;
		    			}
	            	}
	            	
            		var itemLabel = ui.item.label;
            		
            		if(o.callType == "MAIL"){
            			itemLabel = ui.item.UserName + "<" + ui.item.UserCode + ">";
            		}
	            	
	                $("<div></div>")
	                    .addClass("ui-autocomplete-multiselect-item")
	                    .attr("data-json", JSON.stringify(ui.item))
	                    .attr("data-value", ui.item.value)
	                    .text(itemLabel)
	                    .append(
	                        $("<span></span>")
	                            .addClass("ui-icon ui-icon-close")
	                            .click(function(){
	                                var item = $(this).parent();
	                                delete self.selectedItems[item.attr("data-value")];
	                                item.remove();
	                            })
	                    )
	                    .insertBefore(self.element);
	                
	                self.selectedItems[ui.item.value] = ui.item;
	                self._value("");
	                
	                if(o.callBackFunction != ""  && o.callBackFunction != null  && o.callBackFunction != undefined){
	                	window[o.callBackFunction](ui.item);
	                	
	                	self.element.focusout();
	                }
	                
	                return false;
	            }
	        }
	        return this;
	    }
        , setSelect: function(func){
        	var self = this,
            o = self.options;
        	
        	o.select = func;
        }
        , addItem: function(item){
        	var self = this;
        	self.selectedItems[item.value] = item;
        }
        , removeItem: function(item){
        	var self = this;
        	delete self.selectedItems[item.attr("data-value")];
        }
	});
	
})(window);
