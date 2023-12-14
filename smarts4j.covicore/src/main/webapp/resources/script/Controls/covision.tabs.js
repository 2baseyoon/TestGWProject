'use strict';
class CoviTabs{
	constructor() {
		this.dupTab = false;
	    this.currentTab = null;

	    this.tabpanelsStr = [];
	    this.tabIdx = 0;
  }

  createTabs(menuUrl, menuId, menuNm, load ){
		if (menuNm == undefined || menuNm == ''){
//			menuNm = "tab-Menu";
		}
		
		this.tabIdx++;
		let tabId="tab-"+this.tabIdx;

		let arrUrl = menuUrl.split("/");

		let arrName =arrUrl[arrUrl.length-1].split("_");
		let className ;
		if (arrName.length>1){
			className = arrName[0]+arrName[1].split(".")[0];
		}else{
			className = arrUrl[arrUrl.length-2]+arrUrl[arrUrl.length-1].split(".")[0];
			
		}	
		if (!this.dupTab && $(".ui_page_tab[aria-link='"+menuUrl+"']").length>0){	//기존 탭
			let tabId = $(".ui_page_tab[aria-link='"+menuUrl+"']").attr("id");
			this.setSelectedTab(document.querySelector("#"+tabId), true);
		}
		else{
			if ( this.currentTab != null ){
				this.setRemoveTab(this.currentTab);
			}
			
			$(".ui_tab_menu .tab_menu_list").append(
				'<div class="ui_page_tab" data-id="data_'+tabId+'" id="'+tabId+'" aria-selected="true" data-fixed="true" aria-controls="content" aria-link="'+menuUrl+'"  aria-menu="'+menuId+'"  aria-class="'+className+'">'+
				    '<span>'+((menuNm == undefined || menuNm == '')?"":menuNm)+'</span><a href="#"></a>'+
                    '<button type="button" data-icon="pin"><span>고정</span></button>'+
                    '<button type="button" data-icon="refresh"><span>새로고침</span></button>'+
                    '<button type="button" data-icon="tab"><span>새창</span></button>'+
                    '<button type="button" data-icon="close"><span>닫기</span></button>'+
				'</div>');
			
			if (!load)	{
				CoviMenu_GetContent(menuUrl, true, menuId, menuNm, true, tabId);
			}else{//새로고침인 경우 이미 로드 되었기 때문에 tab title만 수정
				$("#tab-1 span:eq(0)").text($("#content .title:eq(0)").text());
			}
	       	var tab = document.querySelector("#"+tabId); //this.tabs[i];
		    this.setCurrentTab(tab);
		    
			tab.addEventListener('keydown', this.onKeydown.bind(this));
			tab.addEventListener('click', this.onClick.bind(this));
		}	
	}
  
  	setRemoveAllTab(){
		var idx = 0;
		var len =  $(".ui_page_tab").size();
		for (let i=0; i< len;i++){
			let currentTarget = document.querySelector("#"+ $(".ui_page_tab:eq("+idx+")").attr("id"));
			if (currentTarget.getAttribute("id") != this.currentTab.getAttribute("id")){ //현재 창이 닫히며
				currentTarget.remove();
				delete this.tabpanelsStr[currentTarget.getAttribute("id")];
			}else{
				idx++;
			}	
		}	
		  
	}

	  
  	setCurrentTab(currentTab){
  		this.currentTab= currentTab;
        history.pushState(null, null, currentTab.getAttribute('aria-link'));

  	}
	setSelectedTab(currentTab, setFocus) {
		if ( this.currentTab != null && this.currentTab != currentTab){
			this.setRemoveTab(this.currentTab);
		}
		
	    if (typeof setFocus !== 'boolean') {
	      setFocus = true;
	    }
	    
	    if (this.currentTab != currentTab){
		    var tab = currentTab;
		    var tabId = tab.getAttribute("id");
		    tab.setAttribute('aria-selected', 'true');
	        tab.removeAttribute('tabindex');
	
	        if (this.tabpanelsStr[tabId] != null){
	        	let clsys = CoviMenu_getParameterByName('CLSYS', tab.getAttribute('aria-link')).toLowerCase();
	        	
	        	$(".commContLeft[data-section!="+clsys+"]").hide();
	        	$(".commContLeft[data-section="+clsys+"]").show();
	        	
		        $("#"+tab.getAttribute('aria-controls')).replaceWith(this.tabpanelsStr[tabId]);
		        try{
		        	let tabInit = new Function("a","b", ""+tab.getAttribute('aria-class')+".initContent(a, b)");
		        	tabInit(true, tab.getAttribute('aria-link'));
		        }catch(e){
//		        		$("#"+tabId+" span:eq(0)").css("color","red");
	        		$("#"+tabId+" span:eq(0)").wrap("<em>");
		        }
	        }    
	        if (setFocus) {
	          tab.focus();
	        }
		    this.setCurrentTab(currentTab);
	    }    
	}
	    
	setRemoveTab(tab){
	    tab.setAttribute('aria-selected', 'false');
		tab.tabIndex = -1;
		$("#"+tab.getAttribute('aria-controls')+" select").each(function(){
		  	var selIdx = this.selectedIndex;
		    for(var idx = 0; idx < this.options.length; idx ++){
		    	if(idx == selIdx){
		      	this.options[idx].setAttribute("selected", "selected");
		      }else{
		      	this.options[idx].removeAttribute("selected");
		      }
		    }
		  });
	    this.tabpanelsStr [tab.getAttribute('id')]=$("#"+tab.getAttribute('aria-controls')).clone();
	    $("#"+tab.getAttribute('aria-controls')).empty();
	}
	
	setSelectedToPreviousTab(currentTab) {
	    var index  =  $(".ui_page_tab").index(currentTab);

	    if (index === 0) {//첫번째 탭이면 
		   this.setSelectedTab(document.getElementById($(".ui_page_tab:eq("+($(".ui_page_tab").size()-1)+")").attr("id")));
	    } else {
			this.setSelectedTab(document.getElementById($(".ui_page_tab:eq("+(index-1)+")").attr("id")));
	    }
	  }

	  setSelectedToNextTab(currentTab) {
		var index  =  $(".ui_page_tab").index(currentTab);

	    if (index === $(".ui_page_tab").size()-1) {//마지막 탭이면
	      this.setSelectedTab(document.getElementById($(".ui_page_tab:eq(0)").attr("id")));
	    } else {
			this.setSelectedTab(document.getElementById($(".ui_page_tab:eq("+(index+1)+")").attr("id")));
	    }
	  }

	  /* EVENT HANDLERS */

	  onKeydown(event) {
	    var tgt = event.currentTarget,
	    flag = false;

	    switch (event.key) {
	      case 'ArrowLeft':
	        this.setSelectedToPreviousTab(tgt);
	        flag = true;
	        break;

	      case 'ArrowRight':
	        this.setSelectedToNextTab(tgt);
	        flag = true;
	        break;

	      case 'Home':
	        this.setSelectedTab(document.getElementById($(".ui_page_tab:eq(0)").attr("id")));
	        flag = true;
	        break;

	      case 'End':
	        this.setSelectedTab(document.getElementById($(".ui_page_tab:eq("+($(".ui_page_tab").size()-1)+")").attr("id")));
	        flag = true;
	        break;

	      default:
	        break;
	    }

	    if (flag) {
	      event.stopPropagation();
	      event.preventDefault();
	    }
	  }

	  onClick(event) {
		event.stopPropagation();
		event.preventDefault();

		switch (event.target.getAttribute('data-icon')){
			case "pin":	//고정
				break;
			case "tab":	//새창
				window.open(event.currentTarget.getAttribute("aria-link"), '_blank');
				break;
			case "close":

				if ($(".ui_page_tab").size() == 1){
					alert("cannot be closed[only one]");
					break;
				}else{
					if (event.currentTarget.getAttribute("id") == this.currentTab.getAttribute("id")){ //현재 창이 닫히며
						$("#"+this.currentTab.getAttribute('aria-controls')).empty();
				        this.setSelectedToPreviousTab(this.currentTab);
					}
					event.currentTarget.remove();
					delete this.tabpanelsStr[event.currentTarget.getAttribute("id")];
				}	
				break;
			case "refresh":	//새로고침
				if (event.currentTarget.getAttribute("id") == this.currentTab.getAttribute("id")){ //active tab 인경우만 
					let menuUrl = event.currentTarget.getAttribute("aria-link");
					CoviMenu_GetContent(menuUrl, false,  event.currentTarget.getAttribute("aria-menu"), "", true, this.currentTab.getAttribute("id"));
				}	
				break;
			default:	
			    this.setSelectedTab(event.currentTarget);
		}
		  
  
	  }

}
$(window).load(function() {
	
	//모든 탭 닫기
	$(document).on('click', '.ui_more_context_menu .ui_button[data-close-type="all"]', function () {
		coviTabs.setRemoveAllTab();
	});
});
