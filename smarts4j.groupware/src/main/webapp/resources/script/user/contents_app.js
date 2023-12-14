var contentsApp = {
	
	drawComponent:function(type){
		
		var returnObj = null;
		
		contentsApp.addData(cid, type);
		
		switch(type){
			case "Input" : returnObj = $("<div>",{"class":"component","data-type":"Input","data-cid":cid})
	          	.append($("<label>",{"text":"텍스트"}))
	          	.append($("<input>",{"type":"text","value":""}))
		        .append($("<div>",{"class":"compbtn"})
		          	.append($("<a>",{"class":"copy","text":"복사","href":"javascript:void(0);"}))
		          	.append($("<a>",{"class":"remove","text":"삭제","href":"javascript:void(0);"})));
			break;
			case "TextArea" : returnObj = $("<div>",{"class":"component","data-type":"TextArea","data-cid":cid})
	          	.append($("<label>",{"text":"멀티 텍스트"}))
	          	.append($("<textarea>"))
		        .append($("<div>",{"class":"compbtn"})
		          	.append($("<a>",{"class":"copy","text":"복사"}))
		          	.append($("<a>",{"class":"remove","text":"삭제"})));
			break;
			case "Number" : returnObj = $("<div>",{"class":"component w50","data-type":"Number","data-cid":cid})
	          	.append($("<label>",{"text":"숫자"}))
	          	.append($("<input>",{"type":"number","value":""}))
		        .append($("<div>",{"class":"compbtn"})
		          	.append($("<a>",{"class":"copy","text":"복사"}))
		          	.append($("<a>",{"class":"remove","text":"삭제"})));
			break;
			case "DropDown" : returnObj = $("<div>",{"class":"component w50","data-type":"DropDown","data-cid":cid})
	          	.append($("<label>",{"text":"드롭박스"}))
	          	.append($("<select>",{"class":"selectType02"})
	          			.append($("<option>",{"text":"사용"}))
	          			.append($("<option>",{"text":"미사용"})))
	          	.append($("<div>",{"class":"compbtn"})
		          	.append($("<a>",{"class":"copy","text":"복사"}))
		          	.append($("<a>",{"class":"remove","text":"삭제"})));
			break;
			case "CheckBox" : returnObj = $("<div>",{"class":"component w50","data-type":"CheckBox","data-cid":cid})
	          	.append($("<label>",{"text":"체크박스"}))
	          	.append($("<div>",{"class":"checkbox_div"})
	          		.append($("<div>",{"class":"chkStyle01"})
	          			.append($("<input>",{"type":"checkbox","value":"","id":"boxdetail_checkbox"+cid+"_1"}))
	          			.append($("<label>",{"for":"boxdetail_checkbox"+cid+"_1"})
	          				.append($("<span>")).append("옵션1")))
	          		.append($("<div>",{"class":"chkStyle01"})
	          			.append($("<input>",{"type":"checkbox","value":"","id":"boxdetail_checkbox"+cid+"_2"}))
	          			.append($("<label>",{"for":"boxdetail_checkbox"+cid+"_2"})
	          				.append($("<span>")).append("옵션2")))
	          		.append($("<div>",{"class":"chkStyle01"})
	          			.append($("<input>",{"type":"checkbox","value":"","id":"boxdetail_checkbox"+cid+"_3"}))
	          			.append($("<label>",{"for":"boxdetail_checkbox"+cid+"_3"})
	          				.append($("<span>")).append("옵션3"))))
		        .append($("<div>",{"class":"compbtn"})
		          	.append($("<a>",{"class":"copy","text":"복사"}))
		          	.append($("<a>",{"class":"remove","text":"삭제"})));
			break;
			case "Radio" : returnObj = $("<div>",{"class":"component w50","data-type":"Radio","data-cid":cid})
	          	.append($("<label>",{"for":"comp_data05","text":"단일 선택"}))
	          		.append($("<div>",{"class":"radioStyle05"})
	          			.append($("<input>",{"type":"radio","value":"","id":"boxdetail_radio"+cid+"_1","name":"boxdetail_radio"+cid}))
	          			.append($("<label>",{"for":"boxdetail_radio"+cid+"_1"})
	          				.append("선택안함")))
	          		.append($("<div>",{"class":"radioStyle05"})
	          			.append($("<input>",{"type":"radio","value":"","id":"boxdetail_radio"+cid+"_2","name":"boxdetail_radio"+cid}))
	          			.append($("<label>",{"for":"boxdetail_radio"+cid+"_2"})
	          				.append("옵션1")))
	          		.append($("<div>",{"class":"radioStyle05"})
	          			.append($("<input>",{"type":"radio","value":"","id":"boxdetail_radio"+cid+"_3","name":"boxdetail_radio"+cid}))
	          			.append($("<label>",{"for":"boxdetail_radio"+cid+"_3"})
	          				.append("옵션2")))
	          		.append($("<div>",{"class":"radioStyle05"})
	          			.append($("<input>",{"type":"radio","value":"","id":"boxdetail_radio"+cid+"_4","name":"boxdetail_radio"+cid}))
	          			.append($("<label>",{"for":"boxdetail_radio"+cid+"_4"})
	          				.append("옵션3")))
		        .append($("<div>",{"class":"compbtn"})
		          	.append($("<a>",{"class":"copy","text":"복사"}))
		          	.append($("<a>",{"class":"remove","text":"삭제"})));
			break;
			case "ListBox" : returnObj = $("<div>",{"class":"component w50","data-type":"ListBox","data-cid":cid})
	          	.append($("<label>",{"text":"리스트박스"}))
	          		.append($("<div>",{"class":"listbox"})
	          			.append($("<div>",{"class":"chkStyle01"})
		          			.append($("<input>",{"type":"checkbox","value":"","id":"ccc06"}))
		          			.append($("<label>",{"for":"ccc06"})
	          					.append($("<span>")).append("옵션1")))
	          			.append($("<div>",{"class":"chkStyle01"})
		          			.append($("<input>",{"type":"checkbox","value":"","id":"ccc07"}))
		          			.append($("<label>",{"for":"ccc07"})
	          					.append($("<span>")).append("옵션2")))
	          			.append($("<div>",{"class":"chkStyle01"})
		          			.append($("<input>",{"type":"checkbox","value":"","id":"ccc08"}))
		          			.append($("<label>",{"for":"ccc08"})
	          					.append($("<span>")).append("옵션3")))
	          			.append($("<div>",{"class":"chkStyle01"})
		          			.append($("<input>",{"type":"checkbox","value":"","id":"ccc09"}))
		          			.append($("<label>",{"for":"ccc09"})
	          					.append($("<span>")).append("옵션4"))))
		        .append($("<div>",{"class":"compbtn"})
		          	.append($("<a>",{"class":"copy","text":"복사"}))
		          	.append($("<a>",{"class":"remove","text":"삭제"})));
			break;
			case "Date" : returnObj = $("<div>",{"class":"component w50","data-type":"Date","data-cid":cid})
	          	.append($("<label>",{"for":"comp_data08","text":"날짜"}))
	          	.append($("<div>",{"class":"dateSel type02"})
          			.append($("<input>",{"class":"adDate","type":"text","value":"2021.06.30","id":"comp_data08"}))
          			.append($("<a>",{"class":"icnDate"})
          				.append("날짜선택1")))
		        .append($("<div>",{"class":"compbtn"})
		          	.append($("<a>",{"class":"copy","text":"복사"}))
		          	.append($("<a>",{"class":"remove","text":"삭제"})));
			break;
			case "DateTime" : returnObj = $("<div>",{"class":"component w50","data-type":"DateTime","data-cid":cid})
	          	.append($("<label>",{"for":"comp_data10","text":"날짜와 시간"}))
	          	.append($("<div>",{"class":"dateSel type02"})
          			.append($("<input>",{"class":"adDate","type":"text","value":"2021.06.30","id":"comp_data10"}))
          			.append($("<a>",{"class":"icnDate"})
          				.append("날짜선택"))
	          		)
		        .append($("<div>",{"class":"compbtn"})
		          	.append($("<a>",{"class":"copy","text":"복사"}))
		          	.append($("<a>",{"class":"remove","text":"삭제"})));
			break;
			case "Label" : returnObj = $("<div>",{"class":"component","data-type":"Label","data-cid":cid})
	          	.append($("<label>",{"text":"라벨"}))
		        .append($("<div>",{"class":"compbtn"})
		          	.append($("<a>",{"class":"copy","text":"복사"}))
		          	.append($("<a>",{"class":"remove","text":"삭제"})));
			break;
			case "Line" : returnObj = $("<div>",{"class":"component","data-type":"Line","data-cid":cid})
	          	.append($("<div>",{"class":"line"}))
		        .append($("<div>",{"class":"compbtn"})
		          	.append($("<a>",{"class":"copy","text":"복사"}))
		          	.append($("<a>",{"class":"remove","text":"삭제"})));
			break;
			case "Space" : returnObj = $("<div>",{"class":"component","data-type":"Space","data-cid":cid})
	          	.append($("<div>",{"class":"whitespace"})
	          		.append("빈 영역 입니다."))
		        .append($("<div>",{"class":"compbtn"})
		          	.append($("<a>",{"class":"copy","text":"복사"}))
		          	.append($("<a>",{"class":"remove","text":"삭제"})));
			break;
			case "Button" : returnObj = $("<div>",{"class":"component","data-type":"Button","data-cid":cid})
	          	.append($("<div>",{"align":"center"})
	          		.append($("<a>",{"class":"btnTypeDefault btnTypeBg","text":"버튼"})))
		        .append($("<div>",{"class":"compbtn"})
		          	.append($("<a>",{"class":"copy","text":"복사"}))
		          	.append($("<a>",{"class":"remove","text":"삭제"})));
			break;
			case "Image" : returnObj = $("<div>",{"class":"component","data-type":"Image","data-cid":cid})
	          	.append($("<label>",{"text":"이미지"}))
				.append($("<div>",{"class":"imgSelect","align":"center"})
					.append($("<div>",{"class":"designImgAdd"})
						.append($("<a>",{"href":"#","class":"fileSelect","text":"파일을 선택해주세요."}))
						.append($("<img>",{"class":"l_img1","onerror":"coviCtrl.imgError(this);"}))
						.append($("<a>",{"href":"#","class":"btn_del","style":"display: none;"}))
					)
					.append($("<input>",{"type":"file","style":"display: none;"}))
					.append($("<input>",{"type":"hidden","class":"inputPath","id":"hid_pcLogoPath"}))
				)
		        .append($("<div>",{"class":"compbtn"})
		          	.append($("<a>",{"class":"copy","text":"복사"}))
		          	.append($("<a>",{"class":"remove","text":"삭제"})));
			break;
			case "Help" : returnObj = $("<div>",{"class":"component","data-type":"Help","data-cid":cid})
	          	.append($("<div>",{"style":"text-align: center;"})
	          		.append($("<a>",{"class":"btnTypeDefault btnTypeBg","text":"도움말"})))
		        .append($("<div>",{"class":"compbtn"})
		          	.append($("<a>",{"class":"copy","text":"복사"}))
		          	.append($("<a>",{"class":"remove","text":"삭제"})));
			break;
			default: returnObj = $("<div>",{"class":"component","data-type":"Input","data-cid":cid})
	          	.append($("<label>",{"text":"텍스트"}))
	          	.append($("<input>",{"type":"text","value":""}))
		        .append($("<div>",{"class":"compbtn"})
		          	.append($("<a>",{"class":"copy","text":"복사","href":"#"}))
		          	.append($("<a>",{"class":"remove","text":"삭제"})));
			break;
		}
		
		cid++;
		
		return returnObj;
	},
	drawProperty:function(type, cid){
		
		$(".cRContProperty .property_inner").children().remove();
		
		var titleContent = "";
		switch(type){
			case "Input" : titleContent = "속성 - 텍스트"; break;
			case "TextArea" : titleContent = "속성 - 멀티 텍스트"; break;
			case "Number" : titleContent = "속성 - 숫자"; break;
			case "DropDown" : titleContent = "속성 - 드롭박스"; break;
			case "CheckBox" : titleContent = "속성 - 체크박스"; break;
			case "Radio" : titleContent = "속성 - 단일 선택"; break;
			case "ListBox" : titleContent = "속성 - 리스트박스"; break;
			case "Date" : titleContent = "속성 - 날짜"; break;
			case "DateTime" : titleContent = "속성 - 날짜와 시간"; break;
			case "Label" : titleContent = "속성 - 라벨"; break;
			case "Line" : titleContent = "속성 - 라인"; break;
			case "Space" : titleContent = "속성 - 공백"; break;
			case "Button" : titleContent = "속성 - 버튼"; break;
			case "Image" : titleContent = "속성 - 이미지"; break;
			case "Help" : titleContent = "속성 - 도움말"; break;
		}
		$(".cRContProperty .title").contents()[0].textContent = titleContent;
		
		//이름
		if(type == "Input" || type == "TextArea" || type == "Number" || type == "Radio" || type == "CheckBox" || type == "DropDown" || type == "ListBox" || type == "Date" || type == "DateTime" || type == "Label" || type == "Button"){
			$(".cRContProperty .property_inner").append($("<div>",{"class":"prop_name"})
				.append($("<label>",{"text":"이름"}))
				.append($("<div>",{"class":"inputBox"})
					.append($("<input>",{"type":"text","value":"텍스트","id":"prop_name_txt"}))
					.append($("<input>",{"type":"hidden","id":"prop_hidNameDicInfo"}))
					.append($("<a>",{"class":"btnTypeDefault btnLang","text":"다국어","id":"propertyDicBtn"}))
				));
				
			if(type == "Input" || type == "TextArea" || type == "Number" || type == "Radio" || type == "CheckBox" || type == "DropDown" || type == "ListBox" || type == "Date" || type == "DateTime")
				$(".cRContProperty .property_inner .prop_name").append($("<div>",{"class":"chkStyle01"})
						.append($("<input>",{"type":"checkbox","id":"prop_name_check"}))
							.append($("<label>",{"for":"prop_name_check"})
								.append($("<span>"))
								.append("이름 숨기기")));
								
			$(".cRContProperty .property_inner .prop_name").append("<hr>");
		}
		
		//설명
		if(type == "Input" || type == "TextArea" || type == "Number" || type == "Radio" || type == "CheckBox" || type == "DropDown" || type == "ListBox" || type == "Date" || type == "DateTime" || type == "Help")
			$(".cRContProperty .property_inner").append($("<div>",{"class":"prop_dec"})
				.append($("<label>",{"text":"설명"}))
				.append($("<input>",{"type":"text","id":"prop_dec_txt","placeholder":"설명을 입력해주세요."}))
				.append($("<div>",{"class":"chkStyle01"})
					.append($("<input>",{"type":"checkbox","id":"prop_dec_check"}))
						.append($("<label>",{"for":"prop_dec_check"})
							.append($("<span>"))
							.append("툴팁으로 표현"))))
			.append("<hr>");
		
		//필수,중복,유사
		if(type == "Input" || type == "TextArea" || type == "Number" || type == "Radio" || type == "CheckBox" || type == "DropDown" || type == "ListBox" || type == "Date" || type == "DateTime")
			$(".cRContProperty .property_inner").append($("<div>",{"class":"prop_required"})
				.append($("<div>",{"class":"chkStyle01"})
					.append($("<input>",{"type":"checkbox","id":"prop_required_check"}))
						.append($("<label>",{"for":"prop_required_check"})
							.append($("<span>"))
							.append("필수 입력 컴포넌트"))));
		
		if(type == "Input")
			$(".cRContProperty .property_inner").append($("<div>",{"class":"prop_overlap"})
				.append($("<div>",{"class":"chkStyle01"})
					.append($("<input>",{"type":"checkbox","id":"prop_overlap_check"}))
						.append($("<label>",{"for":"prop_overlap_check"})
							.append($("<span>"))
							.append("중복 입력값 등록 불가"))));
		
		$(".cRContProperty .property_inner").append("<hr>");
		
		//기본값
		if(type == "Input" || type == "TextArea" || type == "Number" || type == "Date" || type == "DateTime")
			$(".cRContProperty .property_inner").append($("<div>",{"class":"prop_dvalue01"})
				.append($("<label>",{"text":"기본값"}))
				.append($("<input>",{"id":"prop_dvalue01_txt", "type":"text","value":""})))
			.append("<hr>");
		
		//세부항목
		if(type == "Radio" || type == "DropDown" || type == "CheckBox" || type == "ListBox")
			$(".cRContProperty .property_inner").append($("<div>",{"class":"prop_boxdetail"})
				.append($("<span>",{"text":"세부항목"}))
				.append($("<a>",{"class":"btnTypeDefault btnPlusAdd","text":"추가"}))
				.append($("<ul>",{"class":"boxdetail_option"})))
			.append("<hr>");
		
		//레이아웃
		if(type == "Radio" || type == "CheckBox")
			$(".cRContProperty .property_inner").append($("<div>",{"class":"prop_layout"})
				.append($("<label>",{"text":"레이아웃 설정"}))
				.append($("<div>",{"class":"radioStyle05"})
						.append($("<input>",{"type":"radio","id":"prop_layout_radio1","name":"prop_layout_radio"}))
						.append($("<label>",{"for":"prop_layout_radio1"})
								.append("가로")))
				.append($("<div>",{"class":"radioStyle05"})
						.append($("<input>",{"type":"radio","id":"prop_layout_radio2","name":"prop_layout_radio"}))
						.append($("<label>",{"for":"prop_layout_radio2"})
								.append("세로"))))
			.append("<hr>");
		
		//최대글자수
		if(type == "Input" || type == "TextArea")
			$(".cRContProperty .property_inner").append($("<div>",{"class":"prop_maxcntvalue"})
				.append($("<label>",{"text":"최대글자수"}))
				.append($("<input>",{"id":"prop_maxcntvalue_num","type":"number","value":"0"})))
			.append("<hr>");
		
		//최소, 최대
		if(type == "Number")	// || type == "Date" ||type == "DateTime"
			$(".cRContProperty .property_inner").append($("<div>",{"class":"prop_minvalue"})
				.append($("<label>",{"text":"최소값"}))
				.append($("<input>",{"id":"prop_minvalue_num","type":"number","value":"0"})))
			.append("<hr>");
		
		if(type == "Number")	// || type == "Date" ||type == "DateTime"
			$(".cRContProperty .property_inner").append($("<div>",{"class":"prop_maxvalue"})
				.append($("<label>",{"text":"최대값"}))
				.append($("<input>",{"id":"prop_maxvalue_num","type":"number","value":"100"})))
			.append("<hr>");
		
		//필드보기 화면에 표시되는 사이즈(Line 라인 전체, Half 절반)
		$(".cRContProperty .property_inner").append($("<div>",{"class":"prop_fieldsize"})
				.append($("<label>",{"text":"필드보기"}))
				.append($("<div>",{"class":"radioStyle05"})
					.append($("<input>",{"type":"radio","id":"prop_fieldsize1","name":"prop_fieldsize","checked":"checked"}))
						.append($("<label>",{"for":"prop_fieldsize1"})
							.append("전체")))
				.append($("<div>",{"class":"radioStyle05"})
					.append($("<input>",{"type":"radio","id":"prop_fieldsize2","name":"prop_fieldsize"}))
						.append($("<label>",{"for":"prop_fieldsize2"})
							.append("절반")))
				)
			.append("<hr>");
		
		//너비, 높이
		if(type == "Input" || type == "Number" || type == "TextArea" || type == "DropDown"|| type == "CheckBox" || type == "ListBox" || type == "Line" || type == "Button" || type == "Image")
			$(".cRContProperty .property_inner").append($("<div>",{"class":"prop_width"})
				.append($("<label>",{"text":"입력너비 조절"}))
				.append($("<input>",{"type":"number","id":"prop_width_num","value":"100"}))
				.append($("<div>",{"class":"radioStyle05"})
					.append($("<input>",{"type":"radio","id":"prop_width_type1","name":"prop_width_type"}))
						.append($("<label>",{"for":"prop_width_type1"})
							.append("PX")))
				.append($("<div>",{"class":"radioStyle05"})
					.append($("<input>",{"type":"radio","id":"prop_width_type2","name":"prop_width_type","checked":"checked"}))
						.append($("<label>",{"for":"prop_width_type2"})
							.append("%")))
				.append($("<p>",{"class":"explain","text":"* 퍼센트(%) 입력시 비율로 지정"}))
				)
			.append("<hr>");
		
		if(type == "Space")
			$(".cRContProperty .property_inner").append($("<div>",{"class":"prop_height"})
				.append($("<label>",{"text":"입력높이 조절"}))
				.append($("<input>",{"type":"number","id":"prop_height_num","value":"100"}))
				.append($("<div>",{"class":"radioStyle05"})
					.append($("<input>",{"type":"radio","id":"prop_height_type1","name":"prop_height_type"}))
						.append($("<label>",{"for":"prop_height_type1"})
							.append("PX")))
				.append($("<div>",{"class":"radioStyle05"})
					.append($("<input>",{"type":"radio","id":"prop_height_type2","name":"prop_height_type","checked":"checked"}))
						.append($("<label>",{"for":"prop_height_type2"})
							.append("%")))
				.append($("<p>",{"class":"explain","text":"* 퍼센트(%) 입력시 비율로 지정"}))
				)
			.append("<hr>");
		
		if(type == "TextArea")
			$(".cRContProperty .property_inner").append($("<div>",{"class":"prop_row"})
				.append($("<label>",{"text":"입력높이 조절"}))
				.append($("<input>",{"type":"number","id":"prop_row_num","value":"5"}))
				.append($("<div>",{"class":"radioStyle05"})
							.append("줄")))
			.append("<hr>");
		
		//연결링크
		if(type == "Button" || type == "Help" || type == "Image")
			$(".cRContProperty .property_inner").append($("<div>",{"class":"prop_goto_link"})
				.append($("<label>",{"text":"연결링크"}))
				.append($("<input>",{"type":"text","value":"","id":"prop_goto_link_txt","readonly":(type == "Image")?true:false})));
		
		//리스트에 표시
		if(type == "Input" || type == "TextArea" || type == "Number" || type == "Radio" || type == "CheckBox" || type == "DropDown" || type == "ListBox" || type == "Date" || type == "DateTime"){
			$(".cRContProperty .property_inner").append($("<div>",{"class":"prop_show"})
				.append($("<div>",{"class":"chkStyle01"})
					.append($("<input>",{"type":"checkbox","id":"prop_show_check"}))
					.append($("<label>",{"for":"prop_show_check"})
						.append($("<span>"))
						.append("리스트에 표시"))));
						
			$(".cRContProperty .property_inner").append($("<div>",{"class":"prop_search_item"})
				.append($("<div>",{"class":"chkStyle01"})
					.append($("<input>",{"type":"checkbox","id":"prop_search_item_check"}))
					.append($("<label>",{"for":"prop_search_item_check"})
						.append($("<span>"))
						.append("검색 조건 추가"))));
			//제목에 표시
			if(type == "Input" || type == "Number" ){
				$(".cRContProperty .property_inner").append($("<div>",{"class":"prop_show"})
					.append($("<div>",{"class":"chkStyle01"})
						.append($("<input>",{"type":"checkbox","id":"prop_title_check"}))
						.append($("<label>",{"for":"prop_title_check"})
							.append($("<span>"))
							.append("제목으로 사용"))));
			}
		}
		
		
		
	},
	propertyEvent:function(type, cid){	//속성 이벤트
		
		var trgObj = $(".component_wrap .selected");
		
		//속성창 닫기
		$(".cRContProperty").find(".close").off('click').on('click', function(){
			$(".cRContProperty").toggleClass("active");
			$(".component").removeClass("selected");
		});
		
		if(type == "Input" || type == "TextArea" || type == "Number" || type == "Radio" || type == "CheckBox" || type == "DropDown" || type == "ListBox" || type == "Date" || type == "DateTime" || type == "Label" || type == "Button"){
			//이름
			$("#prop_name_txt").off('keyup').on('keyup', function(){
				var val = $(this).val();
				
				if(type == "Button") {
					trgObj.find(".btnTypeDefault").text(val);
				} else {
					var contentsObj = trgObj.find("label:eq(0)").contents();
					contentsObj[contentsObj.length - 1].textContent = val;
				}
				
				contentsApp.changeData(cid, "DisplayName", val);
			});
			
			// 속성 이름 다국어
			$("#propertyDicBtn").off("click").on("click", function(){
				dicType = "prop_name_txt";
				
				var option = {
					lang : lang,
					hasTransBtn : 'true',
					allowedLang : 'ko,en,ja,zh',
					useShort : 'false',
					dicCallback : "folderNameDic_CallBack",
					popupTargetID : 'DictionaryPopup',
					init : "folderNameDicInit"
				};
				
				coviCmn.openDicLayerPopup(option,"DictionaryPopup");
			});
			
			$("#prop_name_txt").on("change", function(){
				var sDictionaryInfo = '';
				sDictionaryInfo = dictionaryInfo(Common.getSession("lang").toUpperCase(), this.value);
				$("#prop_hidNameDicInfo").val(sDictionaryInfo);
				
				contentsApp.changeData(cid, "FieldName", sDictionaryInfo);
			});
		}
		
		if(type == "Input" || type == "TextArea" || type == "Number" || type == "Radio" || type == "CheckBox" || type == "DropDown" || type == "ListBox" || type == "Date" || type == "DateTime" || type == "Help"){
			
			//이름 숨기기
			$("#prop_name_check").off('click').on('click', function(){
				if($(this).is(':checked'))
					trgObj.find("label:eq(0)").attr("style","visibility: hidden");
				else
					trgObj.find("label:eq(0)").attr("style","visibility: block");
					
				contentsApp.changeData(cid, "IsLabel", ($(this).is(':checked')) ? "N" : "Y");
			});
			
			//설명
			$("#prop_dec_txt").off('keyup').on('keyup', function(){
				var val = $("#prop_dec_txt").val();
				contentsApp.tooltip(val);
				
				contentsApp.changeData(cid, "Description", val);
			});
			
			//툴팁으로 표현
			$("#prop_dec_check").off('click').on('click', function(){
				var val = $("#prop_dec_txt").val();
				contentsApp.tooltip(val);
				
				contentsApp.changeData(cid, "IsTooltip", ($(this).is(':checked')) ? "Y" : "N");
			});
			
			//필수 입력 컴포넌트
			$("#prop_required_check").off('click').on('click', function(){
				trgObj.find("label:eq(0)").find(".thstar").remove();
				
				if($(this).is(':checked'))
					trgObj.find("label:eq(0)").prepend($("<span>",{"class":"thstar","text":"*"}));
				
				contentsApp.changeData(cid, "IsCheckVal", ($(this).is(':checked')) ? "Y" : "N");
			});
			
			//중복 입력값 등록 불가
			$("#prop_overlap_check").off('click').on('click', function(){
				contentsApp.changeData(cid, "IsDup", ($(this).is(':checked')) ? "N" : "Y");
			});
			

			//제목 표기
			$("#prop_title_check").off('click').on('click', function(){
				trgObj.find("label:eq(0)").find(".mark_title").remove();
				if($(this).is(':checked')){
					trgObj.find("label:eq(0)").prepend($("<span>",{"class":"mark_title","text":"제목"}));
					contentsApp.changeData(cid, "IsTitle", "Y");
				}	
				else
					contentsApp.changeData(cid, "IsTitle", "N");
			});
			
			//리스트표시
			$("#prop_show_check").off('click').on('click', function(){
				trgObj.find("label:eq(0)").find(".mark_list").remove();
				
				if($(this).is(':checked')){
					if (trgObj.find("label:eq(0) .mark_title").length > 0 ){
						trgObj.find("label:eq(0) .mark_title").after($("<span>",{"class":"mark_list","text":"리스트"}));
					}
					else{
						trgObj.find("label:eq(0)").prepend($("<span>",{"class":"mark_list","text":"리스트"}));
					}
					contentsApp.changeData(cid, "IsList", "Y");
				}else{
					contentsApp.changeData(cid, "IsList", "N");
				}
			});
			
			//검색항목에 표시 여부
			$("#prop_search_item_check").off('click').on('click', function(){
				trgObj.find("label:eq(0)").find(".mark_search").remove();
				if($(this).is(':checked')){
					if (trgObj.find("label:eq(0) span").length > 0 ){
						trgObj.find("label:eq(0) span:last-child").after($("<span>",{"class":"mark_search","text":""}));
					}
					else{
						trgObj.find("label:eq(0)").prepend($("<span>",{"class":"mark_search","text":""}));
					}
					contentsApp.changeData(cid, "IsSearchItem", "Y");
				}	
				else
					contentsApp.changeData(cid, "IsSearchItem", "N");
			});
			
			
		}
		
		if(type == "Input" || type == "Number" || type == "TextArea"){	// || type == "Date" || type == "DateTime"
			//기본값
			$("#prop_dvalue01_txt").off('keyup').on('keyup', function(){
				var val = $(this).val();
				
				contentsApp.changeData(cid, "DefVal", val);
			});
			
			if(type == "Input" || type == "TextArea"){
				//최대 글자수
				$("#prop_maxcntvalue_num").off('keyup').on('keyup', function(){
					var val = $(this).val();
					
					contentsApp.changeData(cid, "FieldLimitCnt", val);
				});
			}
			
			if(type == "Number"){	// || type == "Date" || type == "DateTime"
				//최소 입력수
				$("#prop_minvalue_num").off('keyup').on('keyup', function(){
					var val = $(this).val();
					
					contentsApp.changeData(cid, "FieldLimitMin", val);
				});
				
				//최대 입력수
				$("#prop_maxvalue_num").off('keyup').on('keyup', function(){
					var val = $(this).val();
					
					contentsApp.changeData(cid, "FieldLimitMax", val);
				});
			}
		}
		
		if(type == "Input" || type == "Number" || type == "TextArea" || type == "Date" || type == "DateTime" || type == "DropDown" || type == "CheckBox" || type == "ListBox" || type == "Line" || type == "Button" || type == "Image"){
			//너비 조절
			$("#prop_width_num").off('keyup').on('keyup', function(){
				var val = $(this).val();
				var type = trgObj.attr("data-type");
				var trgObjAdd;
				
				if(type == "Input" || type == "Number")
					trgObjAdd = trgObj.find("input");
				else if(type == "TextArea")
					trgObjAdd = trgObj.find("textarea");
				else 
					trgObjAdd = trgObj.find(".compbtn").prev();
								
				if($("#prop_width_type1").is(':checked'))
					trgObjAdd.attr("style", "width:"+val+"px;");
				else if($("#prop_width_type2").is(':checked'))
					trgObjAdd.attr("style", "width:"+val+"%;");
					
				contentsApp.changeData(cid, "FieldWidth", val);
			});
			$("#prop_width_type1, #prop_width_type2").off('click').on('click', function(){
				var val = $("#prop_width_num").val();
				var type = trgObj.attr("data-type");
				var trgObjAdd;
				
				if(type == "Input" || type == "Number")
					trgObjAdd = trgObj.find("input");
				else if(type == "TextArea")
					trgObjAdd = trgObj.find("textarea");
				else 
					trgObjAdd = trgObj.find(".compbtn").prev();
				
				if($("#prop_width_type1").is(':checked')){
					trgObjAdd.attr("style", "width:"+val+"px;");
					contentsApp.changeData(cid, "FieldWidthUnit", "PX");
				}else if($("#prop_width_type2").is(':checked')){
					trgObjAdd.attr("style", "width:"+val+"%;");
					contentsApp.changeData(cid, "FieldWidthUnit", "%");
				}
			});
		}
		
		if(type == "Space"){
			//높이 조절
			$("#prop_height_num").off('keyup').on('keyup', function(){
				var val = $(this).val();
				var type = trgObj.attr("data-type");
				var trgObjAdd = trgObj.find(".compbtn").prev();
				
				if($("#prop_height_type1").is(':checked'))
					trgObjAdd.attr("style", "height:"+val+"px;");
				else if($("#prop_height_type2").is(':checked'))
					trgObjAdd.attr("style", "height:"+val+"%;");
					
				contentsApp.changeData(cid, "FieldHeight", val);
			});
			$("#prop_height_type1, #prop_height_type2").off('click').on('click', function(){
				var val = $("#prop_height_num").val();
				var type = trgObj.attr("data-type");
				var trgObjAdd = trgObj.find(".compbtn").prev();
				
				if($("#prop_height_type1").is(':checked')){
					trgObjAdd.attr("style", "height:"+val+"px;");
					contentsApp.changeData(cid, "FieldHeightUnit", "PX");
				}else if($("#prop_height_type2").is(':checked')){
					trgObjAdd.attr("style", "height:"+val+"%;");
					contentsApp.changeData(cid, "FieldHeightUnit", "%");
				}
			});
		}
		
		//textarea 높이 조절
		if(type == "TextArea")
			$("#prop_row_num").off('keyup').on('keyup', function(){
				var val = $(this).val();
				trgObj.find("textarea").attr("rows",val);
				contentsApp.changeData(cid, "FieldRow", val);
			});
		
		//라디오, 체크박스, 드롭박스, 리스트박스
		if(type == "Radio" || type == "CheckBox" || type == "DropDown" || type == "ListBox"){
			opt_cnt = $(".boxdetail_option").find("li").length;
			
			//추가
			$(".prop_boxdetail").find(".btnPlusAdd").off('click').on('click', function(){
				opt_cnt++;
				
				if(type == "DropDown")
					trgObjAdd = trgObj.find("select");
				else if(type == "CheckBox")
					trgObjAdd = trgObj.find(".chkStyle01:last");
				else if(type == "Radio")
					trgObjAdd = trgObj.find(".radioStyle05:last");
				else if(type == "ListBox")
					trgObjAdd = trgObj.find(".listbox");
			
				if(type == "Radio" || type == "DropDown"){
					//라디오, 드롭박스
					$(".boxdetail_option").append($("<li>")
						.append($("<div>",{"class":"radioStyle05 no_move_comp"})
							.append($("<input>",{"type":"radio","id":"prop_boxdetail_radio"+opt_cnt,"name":"prop_boxdetail_radio"}))
							.append($("<label>",{"for":"prop_boxdetail_radio"+opt_cnt})
								.append($("<input>",{"type":"text","value":"옵션","style":"width:130px;"}))))
						.append($("<input>",{"type":"hidden","value":"옵션;;;;;;;;;"}))
						.append($("<a>",{"class":"btnTypeDefault option_dic_btn","text":"다국어"}))
						.append($("<span>",{"class":"option_del no_move_comp","style":"padding-left: 15px;"})));
					
					if(type == "Radio"){
						var addObj = $("<div>",{"class":"radioStyle05"})
							.append($("<input>",{"type":"radio","value":"","id":"boxdetail_radio"+cid+"_"+opt_cnt,"name":"boxdetail_radio"+cid}))
							.append($("<label>",{"for":"boxdetail_radio"+cid+"_"+opt_cnt})
								.append("옵션"));
						
						//가로
						if($("#prop_layout_radio1").is(':checked'))
							trgObjAdd.after(addObj);
						//세로
						else if($("#prop_layout_radio2").is(':checked'))
							trgObj.find("ul").append($("<li>")
								.append(addObj));
					}
					else if(type == "DropDown"){
						trgObjAdd.append($("<option>",{"text":"옵션"}));
					}
					
				} else if(type == "CheckBox" || type == "ListBox"){
					//체크박스, 리스트박스
					$(".boxdetail_option").append($("<li>")
						.append($("<div>",{"class":"chkStyle01 no_move_comp"})
							.append($("<input>",{"type":"checkbox","id":"prop_boxdetail_checkbox"+cid+"_"+opt_cnt}))
							.append($("<label>",{"for":"prop_boxdetail_checkbox"+cid+"_"+opt_cnt})
								.append($("<span>"))
								.append($("<input>",{"type":"text","value":"옵션","style":"width:130px;"}))))
						.append($("<input>",{"type":"hidden","value":"옵션;;;;;;;;;"}))
						.append($("<a>",{"class":"btnTypeDefault option_dic_btn","text":"다국어"}))
						.append($("<span>",{"class":"option_del no_move_comp","style":"padding-left: 15px;"})));
					
					var addObj = $("<div>",{"class":"chkStyle01"})
	          			.append($("<input>",{"type":"checkbox","value":"","id":"boxdetail_checkbox"+cid+"_"+opt_cnt}))
	          			.append($("<label>",{"for":"boxdetail_checkbox"+cid+"_"+opt_cnt})
	          				.append($("<span>")).append("옵션"));

					if(type == "CheckBox"){
						//가로
						if($("#prop_layout_radio1").is(':checked'))
							trgObjAdd.after(addObj);
						//세로
						else if($("#prop_layout_radio2").is(':checked'))
							trgObj.find("ul").append($("<li>").append(addObj));
					}
					else if(type == "ListBox"){
						trgObjAdd.append(addObj);
					}
				}
		
				//옵션 이벤트 재호출
				contentsApp.optionEvent(type, cid);
				
				var now_cnt = $(".boxdetail_option").find("li").length;
				var component_data = form_data[cid];
				
				contentsApp.changeData(cid, "OptionCnt", now_cnt);
				contentsApp.changeData(cid, "OptionList", component_data["OptionList"] + "|0^옵션;;;;;;;;;^" + now_cnt + "^N");
			});
			
			//옵션 이벤트 호출
			contentsApp.optionEvent(type, cid);
		}
		
		//레이아웃
		if(type == "Radio" || type == "CheckBox"){
			$("#prop_layout_radio1, #prop_layout_radio2").off('change').on('change', function(){

				if($("#prop_layout_radio1").is(':checked')){
					if(type == "Radio")
						trgObj.find(".radioStyle05").each(function(i, ui) {
							trgObj.find(".compbtn").before($(this).clone());
						});
					else if(type == "CheckBox")
						trgObj.find(".chkStyle01").each(function(i, ui) {
							trgObj.find(".checkbox_div").append($(this).clone());
						});
					
					trgObj.find("ul").remove();
					
					contentsApp.changeData(cid, "FieldAlign", "W");
				} else if($("#prop_layout_radio2").is(':checked')){
					if(type == "Radio"){
						trgObj.find(".compbtn").before($("<ul>"));
						trgObj.find(".radioStyle05").each(function(i, ui) {
							trgObj.find("ul")
								.append($("<li>")
									.append($(this).clone()));
						});
						trgObj.find("ul").siblings(".radioStyle05").remove();
					} else if(type == "CheckBox"){
						trgObj.find(".checkbox_div").append($("<ul>"));
						trgObj.find(".chkStyle01").each(function(i, ui) {
							trgObj.find("ul").append($("<li>")
									.append($(this).clone()));
						});
						trgObj.find("ul").siblings(".chkStyle01").remove();
					}
					
					contentsApp.changeData(cid, "FieldAlign", "H");
				}
			});
		}
		
		//필드보기 화면에 표시되는 사이즈(Line 라인 전체, Half 절반)
		$("#prop_fieldsize1, #prop_fieldsize2").off('click').on('click', function(){
			trgObj.removeClass("w50");
			
			if($("#prop_fieldsize2").is(':checked')){
				trgObj.addClass("w50");
				contentsApp.changeData(cid, "FieldSize", "Half");
			}else{
				contentsApp.changeData(cid, "FieldSize", "Line");
			}
		});
		
		//커스텀 버튼, 도움말
		$("#prop_goto_link_txt").off('keyup').on('keyup', function(){
			var val = $(this).val();
			contentsApp.changeData(cid, "GotoLink", val);
		});
		
	},
	tooltip:function(val){
		//console.log()
		var trgObj = $(".component_wrap .selected");
		var type = trgObj.attr("data-type");
		var trgObjAdd;
		
		if(type == "Input" || type == "Number")
			trgObjAdd = trgObj.find("input");
		else if(type == "TextArea")
			trgObjAdd = trgObj.find("textarea");
		else if(type == "DropDown")
			trgObjAdd = trgObj.find("select");
		else if(type == "CheckBox")
			trgObjAdd = trgObj.find(".checkbox_div");
		else if(type == "Radio")
			trgObjAdd = trgObj.find(".radioStyle05:last");
		else if(type == "ListBox")
			trgObjAdd = trgObj.find(".listbox");
		else if(type == "Date" || type == "DateTime")
			trgObjAdd = trgObj.find(".dateSel");
		else if(type == "Help")
			trgObjAdd = trgObj.find("div:eq(0)");
		
		trgObjAdd.nextAll(".collabo_help02").remove();
		trgObj.find(".comp_ptx").remove();
		if($("#prop_dec_check").is(':checked')){
			//툴팁
			var toolTip = $("<div>",{ "class" : "helppopup"});
			toolTip.append($("<div>",{ "class" : "help_p"})
					.append($("<p>",{ "class" : "helppopup_tit", "text" : "설명" }))
					.append(val));
			
			if(val.length > 0){
				trgObjAdd.after($("<div>",{ "class" : "collabo_help02"})
						.append($("<a>",{ "class" : "help_ico"})));
				
				trgObj.find(".collabo_help02").append(toolTip);
				
				trgObj.find(".collabo_help02").mouseover(function() {
					$(this).find(".help_ico").toggleClass("active");
				});
				
				trgObj.find(".collabo_help02").mouseout(function() {
					$(this).find(".help_ico").toggleClass("active");
				});
			}
		}else{
			if(val.length > 0) trgObjAdd.after($("<div>",{"class":"comp_ptx","text":val}));
		}
	},
	optionEvent:function(type, cid){	//옵션 이벤트 (드롭박스,라디오,체크박스,리스트박스)
		var trgObj = $(".component_wrap .selected");
	
		$(".boxdetail_option").sortable({
		   items: $(".boxdetail_option li"),
		   connectWith: ".boxdetail_option",
		   cancel: ".no_move_comp",
		});
		
		//옵션 드롭
		$( ".cRContProperty" ).droppable({
			drop: function( event, ui ) {
				setTimeout("contentsApp.opteionDropEvent('"+type+"', "+cid+")",10);
			}
		});
		
		//삭제
		$(".prop_boxdetail").find(".option_del").off('click').on('click', function(){
			var idx = $(this).closest("li").index();
			var field_data = form_data[cid];
			var itemList = field_data.OptionList.split("|");
			var newItem = "";
			
			if(type == "DropDown")
				trgObj.find("option").eq(idx).remove();
			else if(type == "CheckBox")
				trgObj.find(".chkStyle01").eq(idx).remove();
			else if(type == "Radio")
				trgObj.find(".radioStyle05").eq(idx).remove();
			else if(type == "ListBox")
				trgObj.find(".chkStyle01").eq(idx).remove();
			
			var j = 0;
			for(var i=0; i<itemList.length; i++){
				if(i != idx){
					if(j > 0) newItem += "|";
					newItem += itemList[i];
					j++;
				}
			}
			
			contentsApp.changeData(cid, "OptionCnt", itemList.length - 1);
			contentsApp.changeData(cid, "OptionList", newItem);
			
			$(this).closest("li").remove();
		});

		//옵션명
		$(".boxdetail_option").find("input").off('keyup').on('keyup', function(){
			var val = $(this).val();
			var idx = $(this).closest("li").index();
			var field_data = form_data[cid];
			var itemList = field_data.OptionList.split("|");
			var newItem = "";

			if(type == "DropDown")
				trgObj.find("option").eq(idx).text(val);
			else if(type == "CheckBox")
				trgObj.find(".chkStyle01").eq(idx).find("label").contents()[1].textContent = val;
			else if(type == "Radio")
				trgObj.find(".radioStyle05").eq(idx).find("label").text(val);
			else if(type == "ListBox")
				trgObj.find(".chkStyle01").eq(idx).find("label").contents()[1].textContent = val;
			
			for(var i=0; i<itemList.length; i++){
				var item = itemList[i].split("^");
				
				if(i > 0) newItem += "|";
				if(i == idx) newItem += item[0]+"^"+val+"^"+item[2]+"^"+item[3];
				else newItem += item[0]+"^"+item[1]+"^"+item[2]+"^"+item[3];
			}
			
			var sDictionaryInfo = '';
			sDictionaryInfo = dictionaryInfo(Common.getSession("lang").toUpperCase(), val);
			var tarHidObj =  $(".boxdetail_option").find("input[type=hidden]").eq(idx);
			tarHidObj.val(sDictionaryInfo);
			
			contentsApp.changeData(cid, "OptionList", newItem);
		});
		
		if(type == "DropDown" || type == "Radio" || type == "CheckBox" || type == "ListBox"){
			//다국어
			$(".option_dic_btn").off('click').on('click', function(){
				event.stopPropagation();
				
				var idx = $(this).closest("li").index();
				
				dicType = "boxdetail_option-"+idx;
				
				var option = {
					lang : lang,
					hasTransBtn : 'true',
					allowedLang : 'ko,en,ja,zh',
					useShort : 'false',
					dicCallback : "folderNameDic_CallBack",
					popupTargetID : 'DictionaryPopup',
					init : "folderNameDicInit"
				};
				
				coviCmn.openDicLayerPopup(option,"DictionaryPopup");
			});
			
			$(".boxdetail_option").find("input[type=text]").on("change", function(){
				var idx = $(this).closest("li").index();
				
				var sDictionaryInfo = '';
				sDictionaryInfo = dictionaryInfo(Common.getSession("lang").toUpperCase(), this.value);
				
				var tarHidObj =  $(".boxdetail_option").find("input[type=hidden]").eq(idx);
				tarHidObj.val(sDictionaryInfo);
			});
		}
		
		//옵션 기본값
		if(type == "DropDown" || type == "Radio")
			$(".boxdetail_option").find("input[type=radio]").off('click').on('click', function(){
				var idx = $(this).closest("li").index();
				var field_data = form_data[cid];
				var itemList = field_data.OptionList.split("|");
				var newItem = "";
				
				if(type == "DropDown")
					trgObj.find("option").eq(idx).prop("selected", true);
				else if(type == "Radio")
					trgObj.find(".radioStyle05").find("input[type=radio]").eq(idx).prop("checked", true);
				
				for(var i=0; i<itemList.length; i++){
					var item = itemList[i].split("^");
					
					if(i > 0) newItem += "|";
					if(i == idx) newItem += item[0]+"^"+item[1]+"^"+item[2]+"^Y";
					else newItem += item[0]+"^"+item[1]+"^"+item[2]+"^N";
				}
				contentsApp.changeData(cid, "OptionList", newItem);
			});
		
		if(type == "CheckBox" || type == "ListBox"){
			$(".boxdetail_option").find("input[type=checkbox]").off('click').on('click', function(){
				var idx = $(this).closest("li").index();
				var field_data = form_data[cid];
				var itemList = field_data.OptionList.split("|");
				var newItem = "";
				
				if($(this).is(':checked'))
					trgObj.find(".chkStyle01").eq(idx).find("input[type=checkbox]").prop("checked", true);
				else
					trgObj.find(".chkStyle01").eq(idx).find("input[type=checkbox]").prop("checked", false);
				
				for(var i=0; i<itemList.length; i++){
					var item = itemList[i].split("^");
					
					if(i > 0) newItem += "|";
					if(i == idx){
						if($(this).is(':checked'))
							newItem += item[0]+"^"+item[1]+"^"+item[2]+"^Y";
						else
							newItem += item[0]+"^"+item[1]+"^"+item[2]+"^N";
					} else {
						newItem += item[0]+"^"+item[1]+"^"+item[2]+"^"+item[3];
					} 
				}
				contentsApp.changeData(cid, "OptionList", newItem);
			});
			
		}
	},
	opteionDropEvent:function(type, cid){
		
		var newItem = "";
		var trgObj = $(".component_wrap .selected");
		var trgObjAdd;
		var field_data = form_data[cid];
		
		if(type == "DropDown"){
			trgObjAdd = trgObj.find("select");
			trgObj.find("option").remove();
		} else if(type == "CheckBox"){
			trgObjAdd = trgObj.find(".checkbox_div");
			trgObj.find(".chkStyle01").remove();
		} else if(type == "Radio"){
			trgObjAdd = trgObj.find(".compbtn");
			
			if(field_data.FieldAlign == "W") trgObj.find(".radioStyle05").remove();	//가로
			else if(field_data.FieldAlign == "H") trgObj.find("li").remove();	//세로
		} else if(type == "ListBox"){
			trgObjAdd = trgObj.find(".listbox");
			trgObj.find(".chkStyle01").remove();
		}
		
		if(type == "Radio" || type == "DropDown")
			$(".prop_boxdetail").find(".radioStyle05").each(function(i, ui) {
				var idx = $(this).closest("li").index();
				var tarHidObj =  $(".boxdetail_option").find("input[type=hidden]").eq(idx);
				var hidval = tarHidObj.val();
				var opt_name = $(ui).find("input[type=text]").val();
				var opt_checked = $(ui).find("input[type=radio]").is(':checked');
				
				//라디오
				if(type == "Radio"){
					//가로
					if(field_data.FieldAlign == "W")
						trgObjAdd.before($("<div>",{"class":"radioStyle05"})
							.append($("<input>",{"type":"radio","value":"","id":"boxdetail_radio"+cid+"_"+i,"name":"boxdetail_radio"+cid,"checked":opt_checked}))
							.append($("<label>",{"for":"boxdetail_radio"+cid+"_"+i})
								.append(opt_name)));
					//세로
					else if(field_data.FieldAlign == "H")
						trgObj.find("ul").append($("<li>")
						.append($("<div>",{"class":"radioStyle05"})
							.append($("<input>",{"type":"radio","value":"","id":"boxdetail_radio"+cid+"_"+i,"name":"boxdetail_radio"+cid,"checked":opt_checked}))
							.append($("<label>",{"for":"boxdetail_radio"+cid+"_"+i})
								.append(opt_name))));
				}
				
				//드롭박스
				if(type == "DropDown") trgObjAdd.append($("<option>",{"text":opt_name,"selected":opt_checked}));
				
				if(i > 0) newItem += "|";
				newItem += "0^"+hidval+"^"+i+"^";
				newItem += (opt_checked)?"Y":"N";
			});
		
		if(type == "CheckBox" || type == "ListBox")
			$(".prop_boxdetail").find(".chkStyle01").each(function(i, ui) {
				var idx = $(this).closest("li").index();
				var tarHidObj =  $(".boxdetail_option").find("input[type=hidden]").eq(idx);
				var hidval = tarHidObj.val();
				var opt_name = $(ui).find("input[type=text]").val();
				var opt_checked = $(ui).find("input[type=checkbox]").is(':checked');
				
				var addObj = $("<div>",{"class":"chkStyle01"})
						.append($("<input>",{"type":"checkbox","value":"","id":"boxdetail_checkbox"+cid+"_"+i,"name":"boxdetail_checkbox"+cid,"checked":opt_checked}))
						.append($("<label>",{"for":"boxdetail_checkbox"+cid+"_"+i})
							.append($("<span>"))
							.append(opt_name));
				
				if(type == "CheckBox" || type == "ListBox"){	//체크박스
					//가로
					if(field_data.FieldAlign == "W")
						trgObjAdd.append(addObj);
					//세로
					else if(field_data.FieldAlign == "H")
						trgObj.find("ul").append($("<li>")
							.append(addObj));
					
				} else if(type == "ListBox"){	//리스트박스
					trgObjAdd.append(addObj);
				}
				
				if(i > 0) newItem += "|";
				newItem += "0^"+hidval+"^"+i+"^";
				newItem += (opt_checked)?"Y":"N";
			});
		
		contentsApp.changeData(cid, "OptionList", newItem);
		
	},
	dataBind:function(type, cid){	//데이터 바인드
		
		//데이터 처리
		if(form_data.length > 0 && form_data.length > cid){
			var field_data = form_data[cid];
			var trgObj = $(".component_wrap .selected");
			
			if(type == "Input" || type == "TextArea" || type == "Number" || type == "Radio" || type == "CheckBox" || type == "DropDown" || type == "ListBox" || type == "Date" || type == "DateTime" || type == "Label" || type == "Button"){
				//이름
				$("#prop_name_txt").val(field_data.DisplayName);
				$("#prop_hidNameDicInfo").val(field_data.FieldName);
				
				if(field_data.IsLabel == "N") 
					$("#prop_name_check").attr("checked", true);
			}
			
			if(type == "Input" || type == "TextArea" || type == "Number" || type == "Radio" || type == "CheckBox" || type == "DropDown" || type == "ListBox" || type == "Date" || type == "DateTime" || type == "Help"){
				//설명
				$("#prop_dec_txt").val(field_data.Description);
				
				//툴팁으로 표시
				if(field_data.IsTooltip == "Y")
					$("#prop_dec_check").attr("checked", true);
				
				contentsApp.tooltip($("#prop_dec_txt").val());
				
				//필수 입력
				if(field_data.IsCheckVal == "Y") 
					$("#prop_required_check").trigger('click');
					
				//중복 입력값 등록 불가
				if(field_data.IsDup == "N") 
					$("#prop_overlap_check").attr("checked", true);
				
				if(field_data.IsList == "Y")
					$("#prop_show_check").attr("checked", true);
				
				if(field_data.IsTitle == "Y")
					$("#prop_title_check").attr("checked", true);

				/*리스트에 표시
				trgObj.find("label:eq(0)").find(".mark_list").remove();
				if(field_data.IsList == "Y"){
					$("#prop_show_check").attr("checked", true);
					trgObj.find("label:eq(0)").prepend($("<span>",{"class":"mark_list","text":"리스트"}));
				}
				

				trgObj.find("label:eq(0)").find(".mark_title").remove();
				if(field_data.IsTitle == "Y"){
					$("#prop_title_check").attr("checked", true);
					trgObj.find("label:eq(0)").prepend($("<span>",{"class":"mark_title","text":"제목"}));
				}
*/
				if(field_data.IsSearchItem == "Y"){
					$("#prop_search_item_check").attr("checked", true);
				}
				
				
			}
			
			if(type == "Input" || type == "Number" || type == "TextArea"){	// || type == "Date" ||type == "DateTime"
				//기본값
				$("#prop_dvalue01_txt").val(field_data.DefVal);
				
				if(type == "Input" || type == "TextArea"){
					//최대글자수
					$("#prop_maxcntvalue_num").val(field_data.FieldLimitCnt);
				}
			
				if(type == "Number"){
					//최소 입력수
					$("#prop_minvalue_num").val(field_data.FieldLimitMin);
					
					//최대 입력수
					$("#prop_maxvalue_num").val(field_data.FieldLimitMax);
				}
			}
			
			if(type == "Input" || type == "Number" || type == "TextArea" || type == "Date" ||type == "DateTime" || type == "DropDown" || type == "CheckBox" || type == "ListBox" || type == "Line" || type == "Button" || type == "Image"){
				//입력너비 조절
				$("#prop_width_num").val(field_data.FieldWidth);
				
				if(field_data.FieldWidthUnit == "PX")
					$("#prop_width_type1").attr("checked", true);
				else
					$("#prop_width_type2").attr("checked", true);
			}
			
			if(type == "Space"){
				//높이 조절
				$("#prop_height_num").val(field_data.FieldHeight);
				
				if(field_data.FieldHeightUnit == "PX")
					$("#prop_height_type1").attr("checked", true);
				else
					$("#prop_height_type2").attr("checked", true);
			}
			
			if(type == "TextArea"){
				//입력높이 조절
				$("#prop_row_num").val(field_data.FieldRow);
				trgObj.find("textarea").attr("rows", field_data.FieldRow);
			}
			
			//라디오, 체크박스, 드롭박스, 리스트박스
			if(type == "Radio" || type == "CheckBox" || type == "DropDown" || type == "ListBox"){
				
				if(field_data.OptionCnt > 0){
					$(".boxdetail_option").find("li").remove();
					
					var itemList = field_data.OptionList.split("|");
					
					opt_cnt = itemList.length;
					
					for(var i=0; i<itemList.length; i++){
						var item = itemList[i].split("^");
						var optVal = dictionaryLang(Common.getSession("lang").toUpperCase(), item[1]);
					
						if(type == "Radio" || type == "DropDown"){
							//라디오, 드롭박스
							$(".boxdetail_option").append($("<li>")
								.append($("<div>",{"class":"radioStyle05 no_move_comp"})
									.append($("<input>",{"type":"radio","id":"prop_boxdetail_radio"+(i+1),"name":"prop_boxdetail_radio","checked":(item[3]=="Y")?true:false}))
									.append($("<label>",{"for":"prop_boxdetail_radio"+(i+1)})
										.append($("<input>",{"type":"text","value":optVal,"style":"width:130px;"}))))
								.append($("<input>",{"type":"hidden","value":item[1]}))
								.append($("<a>",{"class":"btnTypeDefault option_dic_btn","text":"다국어"}))
								.append($("<span>",{"class":"option_del no_move_comp","style":"padding-left: 15px;"})));
								
						} else if(type == "CheckBox" || type == "ListBox"){
							//체크박스, 리스트박스
							$(".boxdetail_option").append($("<li>")
								.append($("<div>",{"class":"chkStyle01 no_move_comp"})
									.append($("<input>",{"type":"checkbox","id":"prop_boxdetail_checkbox"+(i+1),"checked":(item[3]=="Y")?true:false}))
									.append($("<label>",{"for":"prop_boxdetail_checkbox"+(i+1)})
										.append($("<span>"))
										.append($("<input>",{"type":"text","value":optVal,"style":"width:130px;"}))))
								.append($("<input>",{"type":"hidden","value":item[1]}))
								.append($("<a>",{"class":"btnTypeDefault option_dic_btn","text":"다국어"}))
								.append($("<span>",{"class":"option_del no_move_comp","style":"padding-left: 15px;"})));
						}
					}
					
					//옵션 이벤트 재호출
					contentsApp.optionEvent(type, cid);
				}
			}
			
			//레이아웃
			if(type == "Radio" || type == "CheckBox"){
				if(field_data.FieldAlign == "H")
					$("#prop_layout_radio2").attr("checked",true);
				else
					$("#prop_layout_radio1").attr("checked",true);
			}
			
			//커스텀 버튼, 도움말
			if(type == "Button" || type == "Help" || type == "Image"){
				$("#prop_goto_link_txt").val(field_data.GotoLink);
			}
			
			//필드보기 화면에 표시되는 사이즈(Line 라인 전체, Half 절반)
			trgObj.removeClass("w50");
			if(field_data.FieldSize == "Line"){
				$("#prop_fieldsize1").attr("checked", true);
			} else if(field_data.FieldSize == "Half"){ 
				$("#prop_fieldsize2").attr("checked", true);
				trgObj.addClass("w50");
			}
		}
	
	},
	addData:function(cid, type){	//기본 데이터 추가
		var addArr = {
					DefVal: ""
					, Description: ""
					, DisplayName: ""
					, FieldLimitCnt: ""
					, FieldLimitMax: null
					, FieldLimitMin: null
					, FieldName: ""
					, FieldRow: 0
					, FieldSize: "Line"
					, FieldType: type
					, FieldWidth: 100
					, FieldWidthUnit: "%"
					, FieldHeight: 100
					, FieldHeightUnit: "%"
					, FolderID: 0
					, IsCheckVal: "N"
					, IsDup: "Y"
					, IsLabel: "Y"
					, IsList: "N"
					, IsOption: "N"
					, IsSearchItem: "N"
					, IsTooltip: "N"
					, GotoLink: ""
					, OptionCnt: 0
					, OptionList: null
					, SortKey: 0
					, UserFormID: 0
					, FieldAlign: "W"
					, FieldRow: 0
					, IsTitle : "N"
				};
		
		if(type == "Input"){
			addArr.DisplayName = "텍스트";
			addArr.FieldName = "텍스트;;;;;;;;;";
		} else if(type == "TextArea"){
			addArr.DisplayName = "멀티 텍스트";
			addArr.FieldName = "멀티 텍스트;;;;;;;;;";
		} else if(type == "Number"){
			addArr.DisplayName = "숫자";
			addArr.FieldName = "숫자;;;;;;;;;";
			addArr.FieldSize = "Half";
		} else if(type == "Date"){
			addArr.DisplayName = "날짜";
			addArr.FieldName = "날짜;;;;;;;;;";
			addArr.FieldSize = "Half";
		} else if(type == "DateTime"){
			addArr.DisplayName = "날짜와 시간";
			addArr.FieldName = "날짜와 시간;;;;;;;;;";
			addArr.FieldSize = "Half";
		} else if(type == "Label"){
			addArr.DisplayName = "라벨";
			addArr.FieldName = "라벨;;;;;;;;;";
		} else if(type == "Button"){
			addArr.DisplayName = "버튼";
			addArr.FieldName = "버튼;;;;;;;;;";
		} else if(type == "Radio"){
			addArr.DisplayName = "단일 선택";
			addArr.FieldName = "단일 선택;;;;;;;;;";
			addArr.FieldSize = "Half";
			addArr.IsOption = "Y";
			addArr.OptionCnt = 4;
			addArr.OptionList = "0^선택안함;;;;;;;;;^0^N|0^옵션1;;;;;;;;;^1^N|0^옵션2;;;;;;;;;^2^N|0^옵션3;;;;;;;;;^3^N";
		} else if(type == "CheckBox"){
			addArr.DisplayName = "체크박스";
			addArr.FieldName = "체크박스;;;;;;;;;";
			addArr.FieldSize = "Half";
			addArr.IsOption = "Y";
			addArr.OptionCnt = 3;
			addArr.OptionList = "0^옵션1;;;;;;;;;^0^N|0^옵션2;;;;;;;;;^1^N|0^옵션3;;;;;;;;;^2^N";
		} else if(type == "DropDown"){
			addArr.DisplayName = "드롭박스";
			addArr.FieldName = "드롭박스;;;;;;;;;";
			addArr.FieldSize = "Half";
			addArr.IsOption = "Y";
			addArr.OptionCnt = 2;
			addArr.OptionList = "0^사용;;;;;;;;;^0^N|0^미사용;;;;;;;;;^1^N";
		} else if(type == "ListBox"){
			addArr.DisplayName = "리스트박스";
			addArr.FieldName = "리스트박스;;;;;;;;;";
			addArr.FieldSize = "Half";
			addArr.IsOption = "Y";
			addArr.OptionCnt = 4;
			addArr.OptionList = "0^옵션1;;;;;;;;;^0^N|0^옵션2;;;;;;;;;^1^N|0^옵션3;;;;;;;;;^2^N|0^옵션4;;;;;;;;;^3^N";
		}
		
		form_data.push(addArr);
	},
	changeData:function(cid, field, value){	// 데이터 변경
	
		var component_data = form_data[cid];
				
		var reqMap = {};
		for (var key in component_data){
			if (key == field) continue;
			reqMap[key] = component_data[key];
		}
		reqMap[field] = value;
		
		form_data.splice(cid, 1, reqMap);
	
	},			
	componentClick:function(form_data){	//컴포넌트 클릭 이벤트
	
		//속성창 열기
		$('.component').off('click').on('click', function(){
			event.stopPropagation();
			
		    $(".component").removeClass("selected");
		    $(this).addClass("selected");
		    
		    var type = $(this).attr('data-type');
		    var datacid = $(this).attr('data-cid');
			var opt_cnt;

		    contentsApp.drawProperty(type, datacid);	//속성창
		    contentsApp.propertyEvent(type, datacid);	//속성 이벤트
			contentsApp.dataBind(type, datacid);		//데이터 바인드
			
		    $(".cRContProperty").addClass("active");
		});
		
		//컴포넌트 복사
		$(".component_wrap").find(".copy").off('click').on('click', function(){
        	event.stopPropagation();
        	$(".cRContProperty").removeClass("active");
        	
        	var componentClone = $(this).closest(".component").clone();
        	componentClone.removeClass("selected");
			componentClone.attr("data-cid", cid);
			$(this).closest(".component").after(componentClone);
			
			//데이터 추가
			org_cid = $(this).closest(".component").data("cid");
			
			var component_data = form_data[org_cid];
			var reqMap = {};
			for (var key in component_data){
				if (key == 'UserFormID') continue;
				reqMap[key] = component_data[key];
			}
			reqMap['UserFormID'] = '';
	
			form_data.push(reqMap);
			
			contentsApp.componentClick(form_data);	//컴포넌트 클릭 이벤트
			
			cid++;
        });
		
		//컴포넌트 삭제
		$(".component_wrap").find(".remove").off('click').on('click', function(){
        	event.stopPropagation();
        	$(".cRContProperty").removeClass("active");

			//데이터 삭제
			org_cid = $(this).closest(".component").data("cid");
			contentsApp.changeData(org_cid, "componentDel", "Y");
        	
        	$(this).closest(".component").remove();
        });
				
	}

}
