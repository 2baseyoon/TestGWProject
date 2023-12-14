<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="egovframework.baseframework.util.PropertiesUtil,egovframework.baseframework.util.RedisDataUtil,egovframework.coviframework.util.SessionCommonHelper,egovframework.baseframework.util.DicHelper"%>
<%@ taglib uri="http://tiles.apache.org/tags-tiles" prefix="tiles"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib uri="/WEB-INF/tlds/covi.tld" prefix="covi" %>
<script type="text/javascript">
//webpart script
var gwPortal = {};
var gwWpSwiper = {};
var wall ;
	$(document).ready(function(){
		
		<c:forEach var="list"  items="${webpart}" varStatus="status">
			try{
				<c:if test="${fn:length(list.initMethod )>0}">
					let WP${list.WebpartID}_data ;		
					let WP${list.WebpartID}_json ;
					<c:if test="${fn:length(list.data)>0}">WP${list.WebpartID}_data = ${list.data}</c:if>				
					<c:if test="${fn:length(list.ExtentionJSON)>0}">WP${list.WebpartID}_json = ${list.ExtentionJSON}</c:if>		
					gwPortal['${list.WebpartID}'] =  ${list.JsModuleName}Obj(WP${list.WebpartID}_data, WP${list.WebpartID}_json, 'Portal', 'WP${list.WebpartID}');
				</c:if>		
			}catch (e){coviCmn.traceLog("webpart load1[${list.WebpartID}] :" +e);}			
		</c:forEach>
		
		<c:forEach var="list"  items="${myWidget}" varStatus="status">
			try{
				changeWebpartLayer('WP${list.WebpartID}','Widget', ${list.ExtentionJSON},'${list.DisplayName}','');
				<c:if test="${fn:length(list.ScriptMethod )>0}">
					let WP${list.WebpartID}_data ;
					let WP${list.WebpartID}_json ;
					<c:if test="${fn:length(list.data)>0}">WP${list.WebpartID}_data = ${list.data};</c:if>				
					<c:if test="${fn:length(list.ExtentionJSON)>0}">WP${list.WebpartID}_json = ${list.ExtentionJSON}</c:if>	
						gwPortal['${list.WebpartID}'] =  ${list.JsModuleName}Obj(WP${list.WebpartID}_data, WP${list.WebpartID}_json, 'Widget', 'WP${list.WebpartID}');
				</c:if>		
			}catch (e){coviCmn.traceLog("webpart load2[${list.WebpartID}] :" +e);}	
		</c:forEach>
		
		<c:forEach var="list"  items="${myContents}" varStatus="status">
			try{
				changeWebpartLayer('WP${list.WebpartID}','Contents', ${list.ExtentionJSON},'${list.DisplayName}', '${list.Reserved1}');
				<c:if test="${fn:length(list.ScriptMethod )>0}">
					let WP${list.WebpartID}_data ;		
					let WP${list.WebpartID}_json ;
					<c:if test="${fn:length(list.data)>0}">WP${list.WebpartID}_data = ${list.data};</c:if>				
					<c:if test="${fn:length(list.ExtentionJSON)>0}">WP${list.WebpartID}_json = ${list.ExtentionJSON}</c:if>	
					<c:if test="${fn:length(list.data)>0 or fn:length(list.ExtentionJSON)>0 }">
						gwPortal['${list.WebpartID}'] =  ${list.JsModuleName}Obj(WP${list.WebpartID}_data, WP${list.WebpartID}_json, 'Contents', 'WP${list.WebpartID}');
					</c:if>	
				</c:if>		
			}catch (e){coviCmn.traceLog("webpart load3[${list.WebpartID}] :" +e);}	
		</c:forEach>
		portalInit();
		//design 관련
	    const $portal = document.querySelector('.ui_portal');
	    const $portalControl = $portal.querySelector('.portal_control');
	    const $portalContainer = $portal.querySelector('.portal_container');
	    const $contentScroll = $portal.querySelector('.my_content_body');

	    if ($portal.getAttribute('data-current-view') !== 'one') {
	        $portal.querySelector('.portal_root').addEventListener('wheel', UI_PortalWheel);
	    }

	    let portalScrollTarget = 'main';

	    function UI_PortalDown() {
	        setTimeout(function () {
	            $portal.classList.add('moving');
	            $portalContainer.style.transform = 'translate3d(0, -' + document.querySelector('.portal_root').clientHeight + 'px, 0)';
	            $portal.setAttribute('data-current-view', 'content');
	            $contentScroll.scrollTop = 0;
	            portalScrollTarget = 'content';
	            UI_Gnb();
	        }, 100);

	        $portalContainer.addEventListener('transitionend', function () {
	            $portal.classList.remove('moving');
	        }, {once: true});
	    }

	    function UI_PortalUp() {
	        setTimeout(function () {
	            $portal.classList.add('moving');
	            $portalContainer.style.transform = 'translate3d(0, 0, 0)';
	            $portal.setAttribute('data-current-view', 'main');
	            portalScrollTarget = 'main';
	            UI_Gnb();
	        }, 100);

	        $portalContainer.addEventListener('transitionend', function () {
	            $portal.classList.remove('moving');
	        }, {once: true});
	    }

	    function UI_PortalWheel(e) {
	        e.stopPropagation();
	        if (portalScrollTarget === 'main' && e.deltaY > 0) {
	        	UI_PortalDown();
	        } else {
	            if (portalScrollTarget === 'content' && e.deltaY < 0 && $contentScroll.scrollTop === 0) {
	            	UI_PortalUp();
	            } else {
	                function contentScroll() {
	                    if (this.scrollTop === 0) {
	                        portalScrollTarget = 'content';
	                    } else {
	                        portalScrollTarget = 'contentScroll';
	                    }
	                }

	                function innerScroll() {
	                    if (this.scrollTop === 0 && $contentScroll.scrollTop === 0) {
	                        portalScrollTarget = 'content';
	                    } else if (this.scrollTop === 0) {
	                        portalScrollTarget = 'contentScroll';
	                    } else {
	                        portalScrollTarget = 'contentInnerScroll';
	                    }
	                }

	                $contentScroll.addEventListener('scroll', contentScroll);
	                const $innerScrolls = $contentScroll.querySelectorAll('[data-custom-scrollbar] .simplebar-content-wrapper');
	                for (let i = 0; i < $innerScrolls.length; i++) {
	                    $innerScrolls[i].addEventListener('scroll', innerScroll);
	                }
	            }
	        }
	    }

	    function UI_PortalContainerResizing() {
	        if ($portal.getAttribute('data-current-view') === 'content') {
	            $portalContainer.style.transform = 'translate3d(0, -' + document.querySelector('.portal_root').clientHeight + 'px, 0)';
	            wall.refresh();
	        }
	    }

	    $portalControl.querySelector('.move.down').addEventListener('click', UI_PortalDown);
	    $portalControl.querySelector('.move.up').addEventListener('click', UI_PortalUp);
	    window.addEventListener('resize', UI_PortalContainerResizing);

	 	// 위젯 삭제
	    $(document).on('click', '.portal_widget .widget_control .delete', function () {
//	    	saveMyContents();
	        $(this).parents('.grid_item').remove();
	        wall.refresh();
        	$("#myContentList").attr("data-move", true);
	    });

	    // 마이컨텐츠 편집
	    $(document).on('click', '.ui_portal .portal_control button.setting', function () {
	        $('.ui_portal').addClass('my_content_editing');
	        if ($('.ui_portal').attr('data-current-view') === 'content') {
	            $portal.querySelector('.portal_root').removeEventListener('wheel', UI_PortalWheel);
	        }
	    });

	    // 마이컨텐츠 편집 취소
	    $(document).on('click', '#cancel_my_content_setting', function () {
	    	if ($("#myContentList").attr("data-move") == "true"){
				location.reload();
	    	}else{
		        //콘텐츠 배경
		        if ($('.my_content_save input:checkbox').attr("data-org") == "Y"){
		        	$('.my_content_save input:checkbox').prop("checked", true); 
		        	$(".ui_portal").removeClass("normal");
				}else{
		        	$('.my_content_save input:checkbox').prop("checked", false); 
		        	$(".ui_portal").addClass("normal");
		        }
	    		$('.ui_portal').removeClass('my_content_editing');
	    		if ($('.ui_portal').attr('data-current-view') === 'content') {
    	            $portal.querySelector('.portal_root').addEventListener('wheel', UI_PortalWheel);
    	        }
	    	}
/*	    	wall.refresh();
	        
	        if ($('.ui_portal').attr('data-current-view') === 'content') {
	            $portal.querySelector('.portal_root').addEventListener('wheel', UI_PortalWheel);
	        }*/
	    });
	    
	    //배경적용 on
	    $(document).on('click', '.my_content_save input:checkbox', function () {
			$(".ui_portal").toggleClass("normal");
	    });
	    
	    $(document).on('click', '#save_my_content_setting', function () {
	    	var optMap = {};
	    	optMap["contentsBg"]=$(".my_content_save input:checkbox").is(":checked") ?"Y":"N";
	    	saveMyContentsOrder("myContentList",0,"Contents", optMap);
	        $('.ui_portal').removeClass('my_content_editing');
	        if ($('.ui_portal').attr('data-current-view') === 'content') {
	            $portal.querySelector('.portal_root').addEventListener('wheel', UI_PortalWheel);
	        }
	    });

	    
	    // 마이컨텐츠 설정 drawer 열기
	    $(document).on('click', '#my_content_add_toggle', function () {
	        $('.ui_portal').removeClass('my_content_editing').addClass('my_content_add');
	        wall.refresh();
	        UI_Drawer('my_content_setting_drawer', 'left');
	    });

	    // 마이컨텐츠 설정 drawer 닫기
	    $(document).on('click', '.my_content_setting_drawer .drawer_dim,.my_content_setting_drawer .drawer_close', function () {
	        $('.ui_portal').removeClass('my_content_add').addClass('my_content_editing');
	    });

	    // 위젯 더보기 토글
	    $(document).on('click', '.widget_option_toggle', function () {
	        const $target = $(this).parents('.widget_card').siblings('.widget_option');
	        if ($(this).is('[aria-pressed="true"]')) {
	            $(this).removeAttr('aria-pressed');
	            $target.attr('hidden', 'hidden');
	        } else {
	            $('.widget_option_toggle').removeAttr('aria-pressed');
	            $(this).attr('aria-pressed', 'true');
	            $('.widget_option').attr('hidden', 'hidden');
	            $target.removeAttr('hidden');
	        }
	    }).on('click.widget_option_toggle', function (event) {
	        if ($(event.target).closest('.widget_option_toggle').length === 0) {
	            $('.widget_option_toggle').removeAttr('aria-pressed');
	            $('.widget_option').attr('hidden', 'hidden');
	        }
	    });

	    // 위젯 더보기 옵션 액션
	    $(document).on('click', '.ui_portal .portal_widget .widget_option button', function () {
	        const $this = $(this);
	        const code = $this.attr('data-action');
	        const $widget = this.parentNode.parentElement;
	        const color = $widget.getAttribute('data-color');
	        switch (code) {
	            case 'edit':
//	                console.log('편집 이벤트');
	                break;
	            case 'setting':
//	                console.log('설정 이벤트');
	                break;
	            case 'hide':
//	                console.log('컨텐츠 숨기기 이벤트');
	                $(this).parents('.grid_item').remove();
	                wall.refresh();
	                break;
	            case 'color':
//	                console.log('위젯색상 변경');
	                const colors = [
	                    {code: 'default', label: '기본'},
	                    {code: 'ivory', label: 'ivory'},
	                    {code: 'mint', label: 'mint'},
	                    {code: 'turquoise', label: 'turquoise'},
	                    {code: 'pink', label: 'pink'},
	                    {code: 'peach', label: 'peach'},
	                ];

	                const $selector = document.createElement('div');
	                $selector.className = 'widget_background_selector';
	                const $selectorList = document.createElement('div');
	                $selectorList.className = 'selector_list';
	                colors.forEach(function (value, index) {
	                    const label = document.createElement('label');
	                    label.dataset.color = value.code;
	                    const input = document.createElement('input');
	                    input.type = 'radio';
	                    input.name = 'color';
	                    input.value = value.code;
	                    if (color === null) {
	                        if (index === 0) {
	                            input.checked = true;
	                        }
	                    } else {
	                        if (value.code === color) {
	                            input.checked = true;
	                        }
	                    }
	                    input.addEventListener('click', function () {
	                    	console.log("color chage:"+$(this).parents('.grid_item').attr("data-id"));
	                    	saveMyContentsWebpartColor($widget, $(this).parents('.grid_item').attr("data-id"),value.code );
	                    	$selector.parentNode.removeChild($selector);
	                    });
	                    const i = document.createElement('i');
	                    const span = document.createElement('span');
	                    span.innerText = value.label;
	                    label.appendChild(input);
	                    label.appendChild(i);
	                    label.appendChild(span);
	                    $selectorList.appendChild(label);
	                });
	                $selector.appendChild($selectorList);
	                $widget.appendChild($selector);
	                break;
	            default:
	                break;
	        }
	    });
	    
	    
	});

	//메일 카운트/목록 호출 정리 추가 시작 
	var gSystemMailCall = false;
	var gPortalMailCount = 0;
	var gMailList = null;
	//메일 카운트/목록 호출 정리 추가 종료 
	
	${javascriptString}
	${myWidgetScripts}
	${myContentsScripts}

	// SimpleBar 적용. 'data-custom-scrollbar' 속성이 들어있는 태그는 모두 SimpleBar가 적용됩니다.
	function customScroll() {
	    if (!/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)) {
	        $('[data-custom-scrollbar]').each(function (index, element) {
	            new SimpleBar(element);
	        });
	    }
	}
	
	
	function portalInit() {
	    wall = new Freewall(".ui_portal .portal_content_widget");
	    wall.reset({
	        draggable: true,
	        selector: '.grid_item',
	        cellW: cellW,
	        cellH: cellH,
	        fixSize: 0,
	        gutterX: 26,
	        gutterY: 26,
	        onResize: function () {
	            wall.refresh();
	        },
	        onBlockMove:function(){
	        	$("#myContentList").attr("data-move", true);
	        },	    
	        onComplete: function () {
	        	UI_Tabs();
		        //swiper()
		        for (var i in gwWpSwiper){
		        	gwWpSwiper[i].update();
		        }

	            $('.ui_portal .portal_content_widget').removeClass('loading');
	        }
	    });
	    wall.fitWidth();	    
	    
	    //메인 위젯 swiper
		new Swiper(".portal_main_widget_swiper", {
	        threshold: 5,
	        slidesPerView: 3,
	        slidesPerGroup: 3,
	        navigation: {
	            nextEl: ".portal_main_widget_button_next",
	            prevEl: ".portal_main_widget_button_prev",
	        }
	    });
	    
	    //swiper()
	    <c:forEach var="list"  items="${myWidget}" varStatus="status">
			<c:if test="${not empty list.ExtentionJSON  && not empty list.ExtentionJSON.swiperInfo }"> 
				if ($("#WP${list.WebpartID}  .swiper").length>0){
					gwWpSwiper['WP${list.WebpartID}'] = coviUtil.drawSwiper('WP${list.WebpartID}',${list.ExtentionJSON.swiperInfo});
				}	
	    	</c:if>
	 	</c:forEach> 
	    <c:forEach var="list"  items="${myContents}" varStatus="status">
			<c:if test="${not empty list.ExtentionJSON  && not empty list.ExtentionJSON.swiperInfo }"> 
				if ($("#WP${list.WebpartID}  .swiper").length>0){
					gwWpSwiper['WP${list.WebpartID}'] = coviUtil.drawSwiper('WP${list.WebpartID}',${list.ExtentionJSON.swiperInfo});
				}	
	    	</c:if>
	 	</c:forEach> 
	 	
	 	customScroll();
	}	

</script>
<div class="portal_container">
		<%if (!SessionCommonHelper.getSessionMapKey("PortalOption","onlyContents","N").equals("Y")){%>
          <div class="portal_main" >

              <div class="portal_logo"><a href="/covicore"><span class="blind"></span></a></div>
				<c:forEach var="list"  items="${webpart}" varStatus="status">
					<div id="WP${list.WebpartID}" data-wepart-id="${list.WebpartID}" class="${list.Reserved3}">
					${covi:convertBase64Dec(list.viewHtml)}
					</div>	
	            </c:forEach> 
             <div class="portal_main_widget" id="main_widget">
              	<div class="swiper portal_main_widget_swiper">
                	<div class="swiper-wrapper">
						<c:forEach var="list"  items="${myWidget}" varStatus="status">
							<div class="swiper-slide" id="WP${list.WebpartID}"><!--${list.DisplayName} ${list.JsFilePath}-->
								<div class="portal_widget simplify ${list.Reserved3}">
									 <div class="widget_card">
									${covi:convertBase64Dec(list.viewHtml)}
									</div>
								</div>	
                           	</div>
                        </c:forEach> 
                    </div>
 					<div class="swiper-button-next portal_main_widget_button_next"><span>다음</span></div>
                    <div class="swiper-button-prev portal_main_widget_button_prev"><span>이전</span></div>
                  </div>    
              </div>
			  
          </div>
          <%} %>
          <div class="portal_content">
              <div class="my_content_body">
                  <div class="portal_content_widget" id="myContentList">
                  		<c:forEach var="list"  items="${myContents}" varStatus="status">
							<div class="grid_item ${list.Reserved4}  ${list.Reserved5}" data-handle=".move" data-id="WP${list.WebpartID}" ><!--${list.DisplayName} ${list.JsFilePath}-->
								<div class="portal_widget ${list.Reserved3}" id="WP${list.WebpartID}" data-color="${list.WebpartColor}" data-swiper="${list.Reserved6}">
								${covi:convertBase64Dec(list.viewHtml)}
								</div>
                           	</div>
                        </c:forEach> 
                  </div>
              </div>
               <div class="my_content_save">
<!--                      <button type="button" class="ui_button primary" id="my_content_add_toggle"><i></i><span>위젯 추가</span></button>-->
                    <label class="ui_switch"><span><%=DicHelper.getDic("lbl_apply_background_image")%></span> <input type="checkbox" <%=(SessionCommonHelper.getSessionMapKey("PortalOption","contentsBg","").equals("Y")?"checked":"")%> data-org="<%=SessionCommonHelper.getSessionMapKey("PortalOption","contentsBg","")%>"><i></i></label>
                    <button type="button" class="ui_button" id="cancel_my_content_setting"><span><%=DicHelper.getDic("btn_Cancel")%></span></button>
                    <button type="button" class="ui_button primary" id="save_my_content_setting"><span><%=DicHelper.getDic("lbl_apply")%></span></button>
                </div>
          </div>
      </div>

	<div class="portal_control">
		<%if (!SessionCommonHelper.getSessionMapKey("PortalOption","onlyContents","N").equals("Y")){%>
       <div class="tip">
           <p><%=DicHelper.getDic("PT_Scroll") %></p>
       </div>
          <%} %>
       <button type="button" class="setting"><span>마이컨텐츠 설정</span></button>
       <button type="button" class="move down"><span>마이컨텐츠로 이동</span></button>
       <button type="button" class="move up"><span>메인으로 이동</span></button>
   </div>
</div>
<div class="portal_widget" hidden>
	<button type="button" class="widget_toggle ui_icon_button">
		<i class="material-icons">navigate_before</i>
		<span>펼침</span>
	</button>
	<div class="widget_container">

	</div>
</div>
	

