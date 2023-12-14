/**
 * 시스템 바로가기
 */
var SystemLinkShortcut ={
	config: {
		dataType: 'BaseCode',								// 기초코드(BaseCode) or 게시판(Board)
		targetID: 'SiteLinkList',							// CodeGroup or FolderID(ex.8088)
		slideYN : 'N',										// dataTaype이 Board일 시 슬라이딩 유무
		webpartType: 'Ptype02',								// portal Type
		webpartClassName: 'ptype02_Link',					// 웹파트 최상단 div 클래스명
		webpartTopClassName: 'ptype02_sday',				// 웹파트 톱영역 클래스명
		webpartTabClassName: 'ptype02_tab',					// 웹파트 탭영역 클래스명
		webpartTabTitleClassName: 'ptype02_tab_normal',		// 웹파트 탭 타이틀 클래스명
		webpartContentTopClassName: 'ptype02_wp_height',	// 웹파트 컨텐츠영역 최상단 클래스명
		webpartContentClassName: 'ptype02_link'				// 웹파트 컨텐츠영역 클래스명
	},
	data:[],
	init: function (data,ext,caller){
		var _ext = (typeof ext == 'object') ? ext : {};
		this.config = $.extend(this.config, _ext);
		this.caller = caller;
		
		if (caller == 'Widget'){
			SystemLinkShortcut.initWidget();
			SystemLinkShortcut.config.webpartType = 'Widget';
		} else {
			if(SystemLinkShortcut.config.webpartType=='Ptype01'){
				$("#SystemLink .webpart-content > div").addClass("mScrollV");
			}else if(SystemLinkShortcut.config.webpartType=='Ptype05'){
				$("#SystemLink > div > div:first-child").html('').append('<h2 class="ic_link"><spring:message code="Cache.lbl_ShortcutBusinessSystem"/></h2>')
			}
			
			$("#SystemLink").addClass(SystemLinkShortcut.config.webpartClassName);
			$("#SystemLink > div").addClass(SystemLinkShortcut.config.webpartTopClassName);
			$("#SystemLink > div > div:first-child").addClass(SystemLinkShortcut.config.webpartTabClassName);
			$("#SystemLink > div > div > a").addClass(SystemLinkShortcut.config.webpartTabTitleClassName);
			$("#SystemLink .webpart-content").addClass(SystemLinkShortcut.config.webpartContentTopClassName);
			$("#SystemLink .webpart-content > div").addClass(SystemLinkShortcut.config.webpartContentClassName);
		}
		
		SystemLinkShortcut.getSystemList();
	},
	initWidget: function(){
		var webpartID = $(".portal_main .widget_work_system").attr("id");
		$("#"+webpartID+" .widget_head h3").text(Common.getDic('WP_54'));
	},
	getSystemList: function(){				
		if(SystemLinkShortcut.config.dataType=='BaseCode'){
			var systemLinkList = Common.getBaseCode(SystemLinkShortcut.config.targetID);
			$.each(systemLinkList.CacheData, function(idx, el){
				var linkData = el;
				linkData.Subject = el.CodeName;
				linkData.LinkURL = el.Reserved1;
				linkData.IconClass = el.Reserved3;
			});
			SystemLinkShortcut.data = systemLinkList.CacheData;
			SystemLinkShortcut.render();
		}else if(SystemLinkShortcut.config.dataType=='Board'){
			$.ajax({
				type: "POST",
				async: true, //동기 방식
				data: {
					"folderID": SystemLinkShortcut.config.targetID
				},
				url: "/groupware/pnPortal/selectSystemLinkBoardList.do",
				success: function(data){
					var listData = data.list;
					if(listData.length > 0){
						SystemLinkShortcut.data = data.list;
						SystemLinkShortcut.render();	
					}
				},
				error: function(response, status, error){
					 CFN_ErrorAjax("/groupware/pnPortal/selectSystemLinkBoardList.do", response, status, error);
				}
			});
		}
	},
	render: function(){
		if (SystemLinkShortcut.config.webpartType == 'Widget'){
			SystemLinkShortcut.renderWidget();
		} else if (SystemLinkShortcut.config.webpartType == 'ptype03'){ 
			$('#ulSystemLinkContents').html('');
			$('#ulSystemLinkContents').addClass("link");
			$.each(SystemLinkShortcut.data, function(idx, el){
				$('#ulSystemLinkContents').append(
					$("#tempSystemLinkLi").html()
						.replace('{link}', (el.LinkURL != '') ? el.LinkURL : '#')
						.replace('{iconClass}', el.IconClass)
						.replace('{linkName}', el.Subject)
				);
			});
		} else {
			var ulWrap = "";
			var liLink = "";
			var liLinkClass = "";
			if(SystemLinkShortcut.config.webpartType == 'Ptype01'){
				liLinkClass = "ptype01_ico_dot";
			}else if(SystemLinkShortcut.config.webpartType == 'Ptype02'){
				liLinkClass = "ptype02_link_list";
			}
	
			if(SystemLinkShortcut.data.length > 0){
				if(SystemLinkShortcut.config.slideYN=='N'){
					$.each(SystemLinkShortcut.data, function(i, item){
						if(item.CodeName != null && item.CodeName != ''){
							ulWrap += "<li>";
							if(item.Reserved1 != null && item.Reserved1 != ''){
								liLink = item.Reserved1;
							}else{
								liLink = "javascript:void(0);";
							}
							ulWrap += '<a href="'+liLink+'" target="_blank"><span class="'+liLinkClass+'">';
							ulWrap += SystemLinkShortcut.config.webpartType!='Ptype01' ? CFN_GetDicInfo(item.MultiCodeName) : "";
							ulWrap += "</span>";
							ulWrap += SystemLinkShortcut.config.webpartType=='Ptype01' ? CFN_GetDicInfo(item.MultiCodeName) : "";
							ulWrap += "</a>";	
							ulWrap += "</li>";
						}
					});
					$('#ulSystemLinkContents').html(ulWrap);
				}else{
					var $fragment = $( document.createDocumentFragment());
					var listData = SystemLinkShortcut.data;
					var liWrap = "";
	
					var len = Math.ceil( listData.length/6 );
					for(i=0; i < len; i++){
						var $ul = $("<ul>");
						$.each(listData.splice(0,6),function(i, item){
							var fileInfo = "";
							var filePath = "/HtmlSite/smarts4j_n/covicore/resources/images/common/systemlink_sample.jpg";
							var liWrap = $("<li></li>");
							
							//item.SavedName && (filePath = backStorage + item.ServiceType + "/" + item.FilePath + item.SavedName);
							if(item.FullPath && item.FullPath.length > 0) filePath = item.FullPath;
							
							if(item.OpenType == "1"){
								openType = "_self";
							}else{
								openType = "_blank";
							}
							if(filePath.indexOf("/HtmlSite/") < 0)filePath = coviCmn.loadImage(filePath);
							liWrap.append($("<a href='#'></a>")
									.append($("<span class='stIcon'></span>")
										.append($("<img>").attr("src", filePath)))
									.append($("<span class='stTxt'></span>").text(item.Subject)));
							
							if(!item.LinkURL || item.LinkURL == "http://"){
								liWrap.find("a").on("click", function(){
									Common.Inform("<spring:message code='Cache.msg_noRegisteredLink'/>"); // 링크가 등록되지 않았습니다.
								});
							}else{
								liWrap.find("a")
									.attr("href", item.LinkURL)
									.attr("target", openType);
							}
							$ul.append( liWrap );
						});
						$fragment.append( $ul );
					}
					$('#ulSystemLinkContents').parent().html('').append($fragment);
					SystemLinkShortcut.setSystemLinkSlide();
				}
			}
		}
		
	},
	setSystemLinkSlide: function(){
		const slider=$("#SystemLink .webpart-content > div:first-child");
		slider.slick({ 
			slide: "ul",			// 슬라이드 되어야 할 태그 ex) div, li
			infinite : true,		// 무한 반복 옵션
			slidesToShow : 1,		// 한 화면에 보여질 컨텐츠 개수
			slidesToScroll : 1,		// 스크롤 한번에 움직일 컨텐츠 개수
			speed : 500,			// 다음 버튼 누르고 다음 화면 뜨는데까지 걸리는 시간(ms)
			arrows : true,			// 옆으로 이동하는 화살표 표시 여부
			dots : false,			// 스크롤바 아래 점으로 페이지네이션 여부
			autoplay : false,		// 자동 스크롤 사용 여부
			autoplaySpeed : 3000,	// 자동 스크롤 시 다음으로 넘어가는데 걸리는 시간 (ms)
			pauseOnHover : true,	// 슬라이드 이동 시 마우스 호버하면 슬라이더 멈추게 설정
			vertical : false,		// 세로 방향 슬라이드 옵션
			draggable : false,		// 드래그 가능 여부
			variableWidth: false
		});
		
		slider.on("wheel", (function(e){
			e.preventDefault();
			if(e.originalEvent.deltaY < 0){
				$(this).slick("slickPrev");
			}else{
				$(this).slick("slickNext");
			}
		}));
	},
	renderWidget: function(){

		$('#ulSystemLinkContents').html('');
		$('#ulSystemLinkContents').addClass("link");
		$.each(SystemLinkShortcut.data, function(idx, el){
			if (idx < 4) {
				$('#ulSystemLinkContents').append(
					$("#tempSystemLinkLi").html()
						.replace('{link}', (el.LinkURL != '') ? el.LinkURL : '#')
						.replace('{iconClass}', 'i'+(idx+1))
						.replace('{linkName}', el.Subject)
				);
			}
		});
	}
}


