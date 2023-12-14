var collabUtil ={
		drawTask:function(item, srcMode, viewMode, dataMode, dragMode, depthCss){
			var obj;
			
			var cardData = {
					"taskSeq":item.TaskSeq, "StartDate":item.StartDate, "EndDate":item.EndDate,
					"prjSeq":item.PrjSeq, "prjType":item.PrjType, "prjName":item.PrjName, "objectType":item.ObjectType,
					"objectID":item.ObjectID, "parentKey":item.ParentKey,
					"taskName":item.TaskName, "userCode":item.UserCode,"authSave":item.authSave
				};
			
			if (srcMode == "TODO"){
				if(item.PrjType == 'P') {
					var aData = item.PrjType + "^" + item.PrjName + "^" + item.PrjColor + "^" + item.SectionName;
					item.PrjDesc = aData;
				} else {
					item.PrjName = (item.PrjName == null) ? "My" : item.PrjName;
				}
			} else {
				item.PrjName = item.ParentKey=="0"?(item.PrjType=="P"?"Project":(item.PrjType!="" && item.PrjType != undefined?"Team":"My")):"";	
			}

			var aUsers = new Array();
			var userData ={};
			if (item.tmUser != null){
				aUsers = item.tmUser.split('|');
				if (aUsers.length>0){
					aUserInfo = aUsers[0].split('^');
					userData= {"code":aUserInfo[0],"type":"U","DisplayName":aUserInfo[1], "PhotoPath":aUserInfo[2], "personCnt":aUsers.length};
					if (aUserInfo.length>2) userData["DeptName"]=aUserInfo[3];
				}	
			}	

			switch (viewMode){
				case "CAL":
					obj = $("<a>",{"class":"coWorkBox","id":"cardTitle"}).data(cardData)
							.append(item.IsMile=='Y'? $("<div>",{"class":"cal_chk milestone"+(item.IsDelay == 'Y'?' mred':'')})
											.append($("<input>",{ "type" : "checkbox", "id":"chk_"+item.TaskSeq, "checked":(item.TaskStatus=="C"?true:false), "disabled":item.authSave =="Y"?false:true}).data( cardData))	
											.append($("<label>",{ "class" : "checkbox", "for":"chk_"+item.TaskSeq})	
												.append($("<span>",{ "class" : "ms_check"}))):"")
							.append( aUsers.length>0?collabUtil.drawProfile(userData, false):"")
							.append($("<span>",{"class":"tx_title"}).text(item.TaskName+"("+item.StartDate+"~"+item.EndDate+")"))
							.append(item.PCnt>0?$("<span>",{"class":"card_share"}).text(item.PCnt):"")
						;
					break;
				case "LIST":  	          	    				
					obj= $("<div>",{ "class" : (depthCss==undefined|| depthCss==""?"listBox_list":depthCss)})
						.append($("<div>",{ "class" : "listBox "+(item.PrjType=="P"?"type02":"type01")+(item.IsDelay == 'Y'?' card_delay':'')+(item.TaskStatus=="C"?" card_complete":"")+(item.Label=='E'?" important":"")+(item.PCnt>0?" deps":"")+(item.ParentKey>0?" sub":""), "data": cardData})
							.append(item.PCnt>0?$("<a>",{ "class" : "btn_arrow_b"}):"")//)<a href="#" class="btn_arrow_b"></a>	
							.append($("<div>",{ "class" : "list_l","id":"cardTitle","data": cardData})
								.append($("<div>",{"class":"list_chk"+(item.IsMile=='Y'?" milestone"+(item.IsDelay == 'Y'?' mred':''):"")})
											.append($("<input>",{ "type" : "checkbox", "id":"chk_"+item.TaskSeq, "checked":(item.TaskStatus=="C"?true:false), "disabled":item.authSave =="Y"?false:true}).data( cardData))	
											.append($("<label>",{ "class" : "checkbox", "for":"chk_"+item.TaskSeq})	
												.append($("<span>",{ "class" : item.IsMile=='Y'?"ms_check":"s_check"}))))
								.append(item.ParentKey=="0"?$("<strong>",{ "class" : "list_type"}).text(item.PrjName):"")
								.append(item.ObjectType != null?$("<strong>",{ "class" : "card_type02","text":item.ObjectType!=""?(item.ObjectType=="EVENT"?"Schedule":item.ObjectType.charAt(0)+item.ObjectType.slice(1).toLowerCase()):""}):"")
								.append($("<strong>",{ "class" : "list_tit"}).text(item.TaskName).data(cardData))
								.append(item.PCnt>0?$("<a>",{"class":"list_share","text":item.PCnt}):""))
							.append($("<div>",{ "class" : "list_r"})
									.append($("<a>",{"class":"list_comment"}).text(item.CommentCnt))
									.append($("<span>",{ "class" : "user_date", "text":coviCmn.getDateFormat(item.EndDate)}))
									.append( aUsers.length>0?collabUtil.drawProfileOne(userData, false):"")
						));
					break;
				default:
					obj= $("<div>",{ "class" : "card "+(item.PrjType=="P"?"type02":"type01")+(item.FileName != null?" card_pic":"")+(item.Label=='E'?" important":"")})
								.append($("<div>",{ "class" :(dragMode=="N"?"":"card_drag ")+"card_cont "+(item.IsDelay == 'Y'?' card_delay':'')+(item.TaskStatus=="C"?" card_complete":"")}).data(cardData)
									.append(item.FileName != null?$("<div>",{"class":"card_img"}).append($("<img>",{"src":coviCmn.loadImageId(item.FileID)}))	:"")	
									.append($("<div>",{ "class" : "card_top"})
										.append($("<strong>",{ "class" : "card_type"}).text(item.PrjName))
										.append(item.ObjectType != null?$("<strong>",{ "class" : "card_type02","text":item.ObjectType!=""?(item.ObjectType=="EVENT"?"Schedule":item.ObjectType.charAt(0)+item.ObjectType.slice(1).toLowerCase()):""}):"")
										.append(coviCmn.isNull(item.SectionName,'')==""|| dataMode == "SEC"?"":$("<strong>",{ "class" : "card_type03","text":item.SectionName}))
										.append(collabUtil.displayDday(item))
										.append($("<div>",{ "class" : "card_chk"+(item.IsMile=='Y'?" milestone"+(item.IsDelay == 'Y'?' mred':''):"")})
											.append($("<input>",{ "type" : "checkbox", "id":"chk_"+item.TaskSeq, "checked":(item.TaskStatus=="C"?true:false),"disabled":item.authSave =="Y"?false:true}).data( cardData))	
											.append($("<label>",{ "class" : "checkbox", "for":"chk_"+item.TaskSeq})	
													.append($("<span>",{ "class" : item.IsMile=='Y'?"ms_check":"s_check"})))
													))
									.append($("<a>",{"id":"cardTitle"}).data(cardData)
										.append($("<strong>",{ "class" : "card_title "+(item.ImpLevel=="H"?"card_up":(item.ImpLevel=="M"?"card_equal":(item.ImpLevel=="L"?"card_down":"")))}).text(item.TaskName).data(cardData))
										.append($("<div>",{"class":"card_info"})
												.append($("<a>",{"class":"card_people"}).text(aUsers.length>0?aUsers[0].split("^")[1]+(aUsers.length>1?"외 "+(aUsers.length-1):""):(item.TmUserCount !== undefined ? item.TmUserCount : "0")))
												.append($("<a>",{"class":"card_comment"}).text(item.CommentCnt))
												.append(item.ObjectType=="SURVEY"?$("<a>",{"class":"card_join","text":Common.getDic("lbl_Run")}):"") //실행
												.append(item.PCnt>0?$("<a>",{"class":"card_share","text":item.PCnt}):"")
												)			
										.append($("<div>",{"class":"card_progress"})
												.append($("<div>",{"class":"card_pgbox"})
														.append($("<div>",{"class":"card_pgbar", "style":"width:"+item.ProgRate+"%"})))
												.append($("<div>",{"class":"card_pgnum"})
														.append($("<span>").text(item.ProgRate+"%"))))
										))
									.append(item.authSave =="Y"?
											$("<div>",{"class":"card_control"})
												.append($("<ul>")
														.append(item.ObjectType==null?$("<li>").append($("<a>",{"class":"btn_card_copy", "id":"cardCopy","text":Common.getDic("lbl_Copy") })):"") //복사
														.append($("<li>").append($("<a>",{"class":"btn_card_modify", "id":"cardModify","text":Common.getDic("lbl_change")}))) //변경
														.append($("<li>").append($("<a>",{"class":"btn_card_delete", "id":"cardDelete","text":Common.getDic("lbl_delete")}))))	 //삭제			
			:""			
												
								);
					break;
			}	
			
			return obj;
		},
		drawAddTask:function(objId, objStartDate, objEndDate, mode){
			if (mode == "LIST"){
				return $("<div>",{ "class" : "pop_listBox listBox input_c"})
						.append($("<div>",{"class":"list_l"})
							.append($("<strong>",{"class" : "list_tit"})
								.append($("<input>",{"type":"text","id":"subTaskName", "class":"HtmlCheckXSS ScriptCheckXSS", "placeholder":Common.getDic("msg_TaskAndPress")})))) //업무를 입력 후 엔터키을 누르세요.
							.append($("<div>",{"class":"org_list_box mScrollV scrollVType01 mCustomScrollbar","id":"subViewMember"}))
						.append($("<div>",{"class":"list_r", "style":"width:100px"})
							.append($("<span>",{"style":"float:left"})
								.append($("<span>",{"text":CFN_GetLocalCurrentDate("yyyy-MM-dd")+"~"+CFN_GetLocalCurrentDate("yyyy-MM-dd"), "id":"viewDate","style":"display:none"}))
								.append($("<span>",{"style" : "width:0px", "id":"subStartDate"}))
								.append($("<span>",{"class" : "btn_list_icon01", "id":"subEndDate"}))
								.append($("<a>",{"class" : "btn_list_icon02"})))
							.append($("<a>",{"class":"btn_close", "style":"padding-left:10px;padding-top:30px", "onclick":"$('.input_c').remove();"})))
					;
			}
			else{
				return $("<div>",{ "class" : "pop_listBox listBox input_c"})
									.append($("<div>",{"class" : "list_chk chkStyle10","style":"width:100%"})
											.append($("<textarea>",{"class":"ta100 add_task","style":"width:100%","placeholder":Common.getDic("msg_TaskAndPress")})))
				  			.append($("<div>",{"class":"commentBtn","style":"display:none"})
									.append($("<p>",{"class":""})
											.append('<input class="adDate title_calendar" type="hidden" id="'+objStartDate+'" date_separator="." readonly  value="'+CFN_GetLocalCurrentDate("yyyy/MM/dd")+'"> '+  
													'<input id="'+objEndDate+'" date_separator="." date_startTargetID="'+objStartDate+'" class="adDate title_calendar" type="text" readonly  value="'+CFN_GetLocalCurrentDate("yyyy/MM/dd")+'">')))
						;
			}				
		},
		drawCalendarTask:function(objId, item, myTodo){
			var schday = item.StartDate;
			//전달에서 넘어온거 체크
			if (item.StartDate < $("#"+objId+" .calMonWeekRow:eq(0) .monShcList td:eq(0) strong").attr("title")){
				schday = $("#"+objId+" .calMonWeekRow:eq(0) .monShcList td:eq(0) strong").attr("title");
			}
			
			var diff = schedule_GetDiffDates (new Date(coviCmn.getDateFormat(schday,"-")), new Date(coviCmn.getDateFormat(item.EndDate,"-")),"day")+1;
			var date = (new Date(coviCmn.getDateFormat(schday,"-"))).getDay();
			
			var week = (new Date(coviCmn.getDateFormat(schday,"-"))).getDay();
			var colspan = 7-week;
			var remain = diff;
			if (diff>colspan){//차주까지 가는 경우
				remain  = diff-colspan;;
			}
			else{
				colspan=diff;
			}
			
			var weekSize = Math.ceil((diff-colspan)/7)+1;
			
			for (var i=0; i < weekSize; i++){
				if (i > 0){
					schday = schedule_SetDateFormat(schedule_AddDays(coviCmn.getDateFormat(schday), colspan),"");
					if (remain > 7) {
						colspan = 7;
						remain = remain - 7;
					}
					else{
						colspan = remain;
					}
				}	
				
				var aFloor = $("#"+objId + " #sum_"+schday).data();
				if (aFloor == undefined) break;	//다음달까지 이어지면 나가기 
				var idx = "-1";
				
				for (var j=1;  j < 4; j++){
					if (aFloor[j+"F"] == "0") {
						idx = (j-1);
						
						for(var k=0; k<colspan; k++) {
							$("#"+objId + " #sum_"+schedule_SetDateFormat(schedule_AddDays(coviCmn.getDateFormat(schday,"-"), k),"")).data(j+"F", "1");
						}
						
						break;
					}
				}

				if (idx == "-1") continue;
				if (colspan > 0){
					$("#"+objId + " #td_"+schday + "_"+idx+"").attr("colspan",colspan);
					for (var k=1; k<colspan;k++){
						$("#"+objId + " #td_"+schedule_SetDateFormat(schedule_AddDays(coviCmn.getDateFormat(schday,"-"), k),"") + "_"+idx+"").remove();
					}	
				}	
				
				var objTask = collabUtil.drawTask(item, myTodo=="Y"?"TODO":"","CAL");
				
				if (item.StartDate< schday) objTask.addClass("nextLine");//이전꺼이면
				if (item.EndDate > schedule_SetDateFormat(schedule_AddDays(coviCmn.getDateFormat(schday,"-"), 7),"")
					|| (weekSize != 1 && i < weekSize -1)) objTask.addClass("prevLine");//아직 종료가 안된 건이면
				
				$("#"+objId + " #td_"+schday + "_"+idx+"").append(objTask);
			}				
		},
		attachEventAutoTags:function(objId, params){
			var autoTagsUrl = "";
			if (params == undefined || params["prjType"] == "M"){
				autoTagsUrl = '/covicore/control/getAllUserGroupAutoTagList.do?onlyUser=Y';
				coviCtrl.setCustomAjaxAutoTags(objId, autoTagsUrl, collabUtil.MultiAutoCommInfos);	//자동완성
			}	
			else{
				autoTagsUrl = String.format("/groupware/collabProject/getProjectMemberList.do?prjSeq={0}&prjType={1}", params["prjSeq"], params["prjType"]);
				coviCtrl.setCustomAjaxAutoTags(objId, autoTagsUrl, collabUtil.MultiAutoInfos);	//자동완성
			}
		},attachEventAddTask:function(objId, objStartDate, objEndDate){
			coviCtrl.setCustomAjaxAutoTags(objId, '/groupware/attendCommon/getAttendUserGroupAutoTagList.do', collabUtil.MultiAutoInfos);	//자동완성
			
			$("#"+objEndDate).bindTwinDate({
				startTargetID : objStartDate,
				separator : "."
			});
			
		},
		displayDday:function(item){
			var txt="";
			var cls = "card_dday"
			if (item.EndDate == null || item.EndDate == "") txt= "";
			if (item.TaskStatus == "C") {
				txt= coviCmn.getDateFormat(item.EndDate);
			}
			else{
				if (item.RemainDay<0){
					txt= 'D+'+(item.RemainDay+"").replace("-","");
					cls += " urgent";
					//cls+= " overdue";
				}else if (item.RemainDay==0){
					txt='D-Day';
				}else if (item.RemainDay<30){
					txt= 'D-'+item.RemainDay;
				}else{
					txt=coviCmn.getDateFormat(item.EndDate);
				}	
				
			}	
			var item = $("<span>",{ "class" : cls, "text": txt});
			return item;
		},//user의 태그를 배열로
		getUserArray:function(objId){
			var trgMemberArr = new Array();
		 	$('#'+objId).find('.user_img').each(function (i, v) {
				var item = $(v);
				var saveData = { "type":item.attr('type'), "userCode":item.attr('code'), "userName":item.data('codeName')};
				trgMemberArr.push(saveData);
			});
		 	return trgMemberArr;
		},		
		loadSlick:function(objId){
    	   $(objId).slick({
    	     slide: 'li',		//슬라이드 되어야 할 태그 ex) div, li
    	     infinite : true, 	//무한 반복 옵션
    	     slidesToShow : 10,		 //한 화면에 보여질 컨텐츠 개수
    	     slidesToScroll : 1,		//스크롤 한번에 움직일 컨텐츠 개수
    	     speed : 500,	  //다음 버튼 누르고 다음 화면 뜨는데까지 걸리는 시간(ms)
    	     arrows : true, 		 //옆으로 이동하는 화살표 표시 여부
    	     dots : false, 		 //스크롤바 아래 점으로 페이지네이션 여부
    	     autoplay : false,			 //자동 스크롤 사용 여부
    	     autoplaySpeed : 3000, 		 //자동 스크롤 시 다음으로 넘어가는데 걸리는 시간 (ms)
    	     pauseOnHover : true,		 //슬라이드 이동	시 마우스 호버하면 슬라이더 멈추게 설정
    	     vertical : false,		 //세로 방향 슬라이드 옵션
    	     draggable : false, 	//드래그 가능 여부
    	     variableWidth: true,
    	     centerMode: false,
    	   });
    	 },
         searchTag : function(params, url, callback){
        	 if (url == undefined) url = "/groupware/collabProject/getMyTask.do";
              $.ajax({
                  type : "POST",
                  url : url,
                  data : params,
                  success : function(res){
                      if(res.result === 'ok'){
                    	  return callback(res);
                      }
                  },
                  error:function (request,status,error){
                  	Common.Error(Common.getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
                  }
              });
         },
         openObjectPopup:function(popupID, openerID, dataMap){//업무 상세화면
			/*switch (dataMap.objectType)
        	 {
	        	 case "SURVEY":
	        		dataMap["State"] = "F";
	        		dataMap["SurveyID"] = dataMap.objectID;
	        		collabMain.openSurveyPopup(dataMap);
	        		break;
        		 default:*/
        			collabUtil.openTaskPopup(popupID, openerID, dataMap.taskSeq, dataMap.taskSeq);
//        		 	break;
 //       	 }
         },
         openTaskPopup:function(popupID, openerID, taskSeq, topTaskSeq, openType){//업무 상세화면
        	
    		var popupYN		= "N";
    		var callBack	= "";
    		var popupUrl	= "/groupware/collabTask/CollabTaskPopup.do?"
    						+ "&taskSeq="    	+ taskSeq
	 						+ "&prjType="    	+ (openerID=="todo"?"":openerID.split("_")[0])
	 						+ "&prjSeq="    	+ (openerID=="todo"?"":openerID.split("_")[1])
    						+ "&topTaskSeq="    + topTaskSeq
    						+ "&popupID="		+ popupID+taskSeq	
    						+ "&openerID="		+ openerID	
    						+ "&popupYN="		+ popupYN	
    						+ "&callBackFunc="	+ callBack	;

    		if (openType == "SELF"){
    			location.replace(popupUrl)
    		}
    		else{	
				try{
					if(collabMenu.myConf["taskShowCode"] == "SLIDING" ){
						collabUtil.openSlidingPopup(popupUrl);
					} else {	//sliding이 아니면 여기로 들어옴
						CFN_OpenWindow(popupUrl, popupID+taskSeq, "800", "900", "","", ""); 
					}	
				} catch (e) {
					CFN_OpenWindow(popupUrl, popupID+taskSeq, "800", "900", "","", ""); 
				}
    		}	

//        		Common.open("", popupID, popupTit, popupUrl, "720px", "825px", "iframe", true, null, null, true);
         },
         openTaskAddPopup:function(popupID, callBack, taskSeq, prjType, prjSeq, sectionSeq, prjName, sectionName, popup){//업무 상세화면
	 		var popupYN		= "N";
	 		var openerID	= "";
	 		var popupUrl	= "/groupware/collabTask/CollabTaskSavePopup.do?"
	 						+ "&taskSeq="    	+ taskSeq
	 						+ "&prjType="    	+ prjType
	 						+ "&prjSeq="    	+ prjSeq
	 						+ "&sectionSeq="    + sectionSeq
	 						+ "&prjName=" 		+ encodeURI(prjName)
	 						+ "&sectionName=" 	+ encodeURI(sectionName)
	 						+ "&popupID="		+ popupID	
	 						+ "&openerID="		+ ""	
	 						+ "&popupYN="		+ popupYN	
	 						+ "&callBackFunc="	+ callBack;
			
			if(popup== "Y" && parent.$("#rightmenu").hasClass("active") == true ){
				parent.$("#rightmenu").removeClass("active");
				// 22.03.02, 문구수정 : 업무관리(lbl_task_taskManage) >> 업무추가(lbl_task_addTask)
				parent.Common.open("", "callbackTaskSave", taskSeq==undefined|| taskSeq==""?Common.getDic("btn_apv_AddTask"):Common.getDic("btn_apv_SaveTask"), popupUrl, "700", "700", "iframe", true, null, null, true);
			} else{
				Common.open("", "callbackTaskSave", taskSeq==undefined|| taskSeq==""?Common.getDic("btn_apv_AddTask"):Common.getDic("btn_apv_SaveTask"), popupUrl, "700", "700", "iframe", true, null, null, true);
			}
			
         },
         openTaskAddPopupFromMessage:function(popupID, callBack, taskSeq, prjType, prjSeq, sectionSeq, prjName, sectionName, popup, bizSection, linkURL, subject, fileInfo){//업무 상세화면
 	 		var popupYN		= "N";
 	 		var openerID	= "";
 	 		var popupUrl	= "/groupware/collabTask/CollabTaskSavePopupFromMessage.do?"
 	 						+ "&taskSeq="    	+ taskSeq
 	 						+ "&prjType="    	+ prjType
 	 						+ "&prjSeq="    	+ prjSeq
 	 						+ "&sectionSeq="    + sectionSeq
 	 						+ "&prjName=" 		+ encodeURI(prjName)
 	 						+ "&sectionName=" 	+ encodeURI(sectionName)
 	 						+ "&popupID="		+ popupID	
 	 						+ "&openerID="		+ ""	
 	 						+ "&popupYN="		+ popupYN	
 	 						+ "&callBackFunc="	+ callBack
 	 						+ "&bizSection=" 	+ bizSection
 	 						+ "&linkURL=" 		+ linkURL
  	 						+ "&subject="		+ subject
  	 						+ "&fileInfo="		+ fileInfo;
 			
 			if(popup== "Y" && parent.$("#rightmenu").hasClass("active") == true ){
 				parent.$("#rightmenu").removeClass("active");
 				// 22.03.02, 문구수정 : 업무관리(lbl_task_taskManage) >> 업무추가(lbl_task_addTask)
 				parent.Common.open("", "callbackTaskSave", taskSeq==undefined|| taskSeq==""?Common.getDic("btn_apv_AddTask"):Common.getDic("btn_apv_SaveTask"), popupUrl, "700", "700", "iframe", true, null, null, true);
 			} else{
 				Common.open("", "callbackTaskSave", taskSeq==undefined|| taskSeq==""?Common.getDic("btn_apv_AddTask"):Common.getDic("btn_apv_SaveTask"), popupUrl, "700", "700", "iframe", true, null, null, true);
 			}
 			
          },
          openTaskAddPopupFromApproval:function(popupID, callBack, taskSeq, prjType, prjSeq, sectionSeq, prjName, sectionName, popup, bizSection, subject, formInstanceID, fileInfo){//업무 상세화면
  	 		var popupYN		= "N";
  	 		var openerID	= "";
  	 		var popupUrl	= "/groupware/collabTask/CollabTaskSavePopupFromApproval.do?"
  	 						+ "&taskSeq="    	+ taskSeq
  	 						+ "&prjType="    	+ prjType
  	 						+ "&prjSeq="    	+ prjSeq
  	 						+ "&sectionSeq="    + sectionSeq
  	 						+ "&prjName=" 		+ encodeURI(prjName)
  	 						+ "&sectionName=" 	+ encodeURI(sectionName)
  	 						+ "&popupID="		+ popupID	
  	 						+ "&openerID="		+ ""	
  	 						+ "&popupYN="		+ popupYN	
  	 						+ "&callBackFunc="	+ callBack
   	 						+ "&bizSection=" 	+ bizSection
  	 						+ "&subject="		+ subject
  	 						+ "&formInstanceID="+ formInstanceID
  	 						+ "&fileInfo="		+ fileInfo;
  			
  			if(popup== "Y" && parent.$("#rightmenu").hasClass("active") == true ){
  				parent.$("#rightmenu").removeClass("active");
  				// 22.03.02, 문구수정 : 업무관리(lbl_task_taskManage) >> 업무추가(lbl_task_addTask)
  				parent.Common.open("", "callbackTaskSave", taskSeq==undefined|| taskSeq==""?Common.getDic("btn_apv_AddTask"):Common.getDic("btn_apv_SaveTask"), popupUrl, "700", "700", "iframe", true, null, null, true);
  			} else{
  				Common.open("", "callbackTaskSave", taskSeq==undefined|| taskSeq==""?Common.getDic("btn_apv_AddTask"):Common.getDic("btn_apv_SaveTask"), popupUrl, "700", "700", "iframe", true, null, null, true);
  			}
  			
        },
        openTaskAddPopupFromMail:function(popupID, callBack, taskSeq, prjType, prjSeq, sectionSeq, prjName, sectionName, popup, bizSection, uid, msgId, boxName, folderTy, userMail){//업무 상세화면
        	var popupYN		= "N";
 	 		var openerID	= "";
 	 		var popupUrl	= "/groupware/collabTask/CollabTaskSavePopupFromMail.do?"
 	 						+ "&taskSeq="    	+ taskSeq
 	 						+ "&prjType="    	+ prjType
 	 						+ "&prjSeq="    	+ prjSeq
 	 						+ "&sectionSeq="    + sectionSeq
 	 						+ "&prjName=" 		+ encodeURI(prjName)
 	 						+ "&sectionName=" 	+ encodeURI(sectionName)
 	 						+ "&popupID="		+ popupID	
 	 						+ "&openerID="		+ ""	
 	 						+ "&popupYN="		+ popupYN	
 	 						+ "&callBackFunc="	+ callBack
 	 						+ "&bizSection=" 	+ bizSection
 	 						+ "&uid=" 			+ uid
 	 						+ "&msgId=" 		+ Base64.utf8_to_b64(decodeURIComponent(msgId))
 	 						+ "&boxName=" 		+ boxName
 	 						+ "&folderTy=" 		+ folderTy
 	 						+ "&userMail=" 		+ userMail;
 			
 			if(popup== "Y" && parent.$("#rightmenu").hasClass("active") == true ){
 				parent.$("#rightmenu").removeClass("active");
 				// 22.03.02, 문구수정 : 업무관리(lbl_task_taskManage) >> 업무추가(lbl_task_addTask)
 				parent.Common.open("", "callbackTaskSave", taskSeq==undefined|| taskSeq==""?Common.getDic("btn_apv_AddTask"):Common.getDic("btn_apv_SaveTask"), popupUrl, "700", "700", "iframe", true, null, null, true);
 			} else{
 				Common.open("", "callbackTaskSave", taskSeq==undefined|| taskSeq==""?Common.getDic("btn_apv_AddTask"):Common.getDic("btn_apv_SaveTask"), popupUrl, "700", "700", "iframe", true, null, null, true);
 			}
 			
        },
		openReportDayPopup:function(popupID, openerID, objId, daySeq){//일일업무보고 상세화면
			var popupYN		= "N";
			var callBack	= "";
			var popupUrl	= "/groupware/collabReport/CollabReportSavePopup.do?"
				+ "&daySeq="    + daySeq
				+ "&objId="    + objId
				+ "&popupID="		+ popupID
				+ "&openerID="		+ openerID
				+ "&popupYN="		+ popupYN
				+ "&callBackFunc="	+ callBack	;
			Common.open("", popupID, "", popupUrl, "700", "500", "iframe", true, null, null, true);
		},
		openReportWeekPopup:function(popupID, openerID, objId, data, prjName){//주간업무보고 상세화면
			var popupYN		= "N";
			var callBack	= "";
			var popupUrl	= "/groupware/collabReport/CollabReportWeekPopup.do?"
				+ "&prjType="    + data.PrjType
				+ "&prjSeq="    + data.PrjSeq
				+ "&prjName="+ encodeURI(prjName)
				+ "&reporterCode="    + data.ReporterCode
				+ "&reporterName="+ encodeURI(CFN_GetDicInfo(data.UserName, lang))
				+ "&startDate="    + data.StartDate
				+ "&endDate="    + data.EndDate
				+ "&objId="    + objId
				+ "&popupID="		+ popupID
				+ "&openerID="		+ openerID
				+ "&popupYN="		+ popupYN
				+ "&callBackFunc="	+ callBack	;

			Common.open("", popupID, "", popupUrl, "700", "500", "iframe", true, null, null, true);
		},
         saveTaskComplete:function(params, callback){         //완료처리
    		$.ajax({
    			type:"POST",
    			data:params,
    			url:"/groupware/collabTask/changeProjectTaskStatus.do",
    			success:function (res) {
    				return callback(res);
    			},
    			error:function (request,status,error){
    				Common.Error(Common.getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
    			}
    		});
         },
     	convertNull:function(orgVal, repalceChar){
    		if (orgVal == null) return repalceChar;
    		else return orgVal;
    	},
         drawProfileOne:function(obj, isDel, subClass){
        	var returnObj = $("<div>",{ "class" : "user_img", code:obj["code"], type:obj["type"], "data":obj, "title":obj["DeptName"]+" | "+obj["DisplayName"]});
        	if (subClass == undefined ) subClass ="";
			
        	if (obj["PhotoPath"]!= null && obj["PhotoPath"]!= "")
        		 returnObj.append($("<p>",{"class" : "bImg"}).append($("<img>",{ "src" : coviCmn.loadImage(obj["PhotoPath"]), "onerror" : "coviCmn.imgError(this, true);" })));
	 		else
	 			returnObj.append($("<p>",{ "class" : "bgColor"+(Math.floor(coviCmn.random() * 5)+1)}).append($("<strong>").text(obj["DisplayName"].substring(1,3))));
	 		
			if(obj["personCnt"] != undefined && obj["personCnt"] > 0) 
				returnObj.append($("<a>",{"class":"btn_member"}).text(obj["personCnt"]));	//담당자수
			
        	return  returnObj.data(obj);
         },
         drawProfile:function(obj, isDel, subClass){
        	if (obj["DeptName"] == undefined && obj["data"] != undefined) obj["DeptName"] = obj["data"]["DeptName"] ;
         	if (obj["PhotoPath"] == undefined&& obj["data"] != undefined) obj["PhotoPath"] = obj["data"]["PhotoPath"]; 
        	var returnObj = $("<div>",{ "class" : "user_img", code:obj["code"], type:obj["type"], "data":obj, "title":obj["DeptName"]+" | "+obj["DisplayName"]});
        	if (subClass == undefined ) subClass ="";
			
        	if (obj["PhotoPath"]!= null && obj["PhotoPath"]!= "")
        		 returnObj.append($("<p>",{"class" : "bImg"}).append($("<img>",{ "src" : coviCmn.loadImage(obj["PhotoPath"]), "onerror" : "coviCmn.imgError(this, true);" })));
	 		else
	 			returnObj.append($("<p>",{ "class" : "bgColor"+(Math.floor(coviCmn.random() * 5)+1)}).append($("<strong>").text(obj["DisplayName"].substring(1,3))));
	 		 
	 		/*
			returnObj.append($("<strong>",{"class":"toolTip1"})
					.append($("<span>",{"text":obj["DeptName"]}))
					.append($("<span>",{"text":obj["DisplayName"]}))
					);*/
			if (isDel){
				returnObj.append($("<a>",{"class":"btn_del "+subClass}).data(obj));
			}	
			
        	return  returnObj.data(obj);
         },
     	 orgMapDivEl : $("<p/>", {'class' : 'bgColor'+(Math.floor(coviCmn.random() * 5)+1), attr : {type : '', code : ''}}).append($("<a/>", {'class' : 'btn_del'})),
    	 MultiAutoInfos : {
    			labelKey : 'DisplayName',
    			valueKey : 'UserCode',
    			minLength : 1,
    			useEnter : false,
    			multiselect : true,
    			select : function(event, ui) {
    				var id = $(document.activeElement).attr('id');
    				var item = ui.item;
    				var type = "UR" ;

    				var cloned = collabUtil.drawProfile({"code":item.UserCode,"type":type,"DisplayName":item.label, "data":item}, true);
    				$(this).before(cloned);

    		    	ui.item.value = ''; // 선택 후 input에 value값이 들어가는 문제가 있어 빈값 처리
    			}		
    	},
	   	 MultiAutoCommInfos : {
				labelKey : 'Name',
				valueKey : 'Code',
				minLength : 1,
				useEnter : false,
				multiselect : true,
				select : function(event, ui) {
					var id = $(document.activeElement).attr('id');
					var item = ui.item;
					
					var cloned = collabUtil.drawProfile({"code":item.Code,"type":item.Type,"DisplayName":item.Name, "data":item}, true);
					$(this).before(cloned);
	
			    	ui.item.value = ''; // 선택 후 input에 value값이 들어가는 문제가 있어 빈값 처리
				}		
	   	 },
    	changeDisplayMode:function(tabId, objId, tabMode, obj){
            obj.parent('.btn').find('.btnListView').removeClass('active');
            obj.closest('.tstab_cont').find('.container-fluid').removeClass('active');
            obj.addClass('active');
            
            $("#"+objId+" #"+tabId).addClass('active');

    		switch (tabMode){
	    		case "GANT":
				case "GANTN":
	    			$("#"+objId+" #calTitle").hide();
	    			$("#"+objId+" #gantTitle").show();
	        		$("#"+objId+" #selType").val("W");  
	    			$("#"+objId+" .tag").hide();
	    			$("#"+objId+" .info").hide();
	    			$("#"+objId+" #calTab").hide();
					$("#"+objId+" #gantTab").hide();
					$("#"+objId+" .Project_filter").hide();
					$("#"+objId+" #dttab-1").css("overflow-y", "auto")	;
					
					

					var stndDateObj  =  new Date(CFN_GetLocalCurrentDate("yyyy-MM-dd"));
					var stndDate =schedule_SetDateFormat(stndDateObj, '-');
					var aCalData = collabUtil.setCalendar(stndDate, objId, "#" + objId + " .gantt .title");
					var startObj= new Date(schedule_SetDateFormat(aCalData["startDate"],"-"));
					var endObj  = new Date(schedule_SetDateFormat(aCalData["endDate"],"-"));
					startObj = startObj.setDate(startObj.getDate()+1);
					endObj = endObj.setDate(endObj.getDate());

	        		$("#"+objId).closest('.cRContBottom').data({"gant_sdate":schedule_SetDateFormat(startObj, '-')
		    	  		,"gant_edate":schedule_SetDateFormat(endObj, '-'),"gant_dateType":$("#"+objId+" #selType").val()});
					
	    			break;
	    		case "CAL":
	    			$("#"+objId+" #calTitle").show();
	    			$("#"+objId+" #gantTitle").hide();
	    			$("#"+objId+" .tag").hide();
	    			$("#"+objId+" .info").hide();
	    			$("#"+objId+" #calTab").show();
					$("#"+objId+" #gantTab").hide();
					$("#"+objId+" .Project_filter").hide();
					$("#"+objId+" #dttab-1").css("overflow-y", "hidden")	;

					var stndDay  =CFN_GetLocalCurrentDate("yyyy-MM-dd");
	    			var aCalData = collabUtil.setCalendar(stndDay, objId, "#"+objId+" .cal .title");
		  	    	$("#"+objId).closest('.cRContBottom').data({"cal_sdate":aCalData["startDate"]
		    	  		,"cal_edate":aCalData["endDate"]});
	    			break;
	            case "LIST"://리스트형
	        		$("#"+objId+" #date1").val("");
	        		$("#"+objId+" #date2").val("");
	    			$("#"+objId+" #calTitle").hide();
	    			$("#"+objId+" #gantTitle").hide();
	    			$("#"+objId+" .tag").show();
	    			$("#"+objId+" .info").show();
	        		$("#"+objId+" #dttab-3").addClass("list-fluid");
	        		$("#"+objId+" #dttab-3").removeClass("card-fluid");
	            	$("#"+objId+" .card_add").hide();
					$("#"+objId+" .Project_filter").show();

	            	break;
	        	default:
	        		$("#"+objId+" #date1").val("");
	        		$("#"+objId+" #date2").val("");
	    			$("#"+objId+" #calTitle").hide();
	    			$("#"+objId+" #gantTitle").hide();
	    			$("#"+objId+" .tag").show();
	    			$("#"+objId+" .info").show();
	        		$("#"+objId+" #dttab-3").removeClass("list-fluid");
	        		
	 				if(($("#"+objId+" #dttab-3").hasClass("mycard-fluid") && obj.hasClass("listViewType02")) || obj.hasClass("listViewType10")) {
						$("#"+objId+" #dttab-3").removeClass("card-fluid");
					} else if(obj.hasClass("listViewType02")){
						$("#"+objId+" #dttab-3").addClass("card-fluid");
					}
					
	            	$("#"+objId+" .card_add").show();
					$("#"+objId+" .Project_filter").show();
					$("#"+objId+" #dttab-1").css("overflow-y", "hidden");
	            	break;
	    	}
    	},
    	setCalendar:function(standDate, objId, titleId){
    		var startDateObj = new Date(standDate);
    		var today = CFN_GetLocalCurrentDate("yyyy-MM-dd")
    		var sDate = schedule_SetDateFormat(new Date(startDateObj.setMonth(startDateObj.getMonth(), 1)), '-');
    		var eDate = schedule_SetDateFormat(new Date(startDateObj.setMonth(startDateObj.getMonth()+1, 0)), '-');
    		var sunday =AttendUtils.getWeekStart(sDate,0);
    		var schday = schedule_SetDateFormat(sunday, '-');
    		//달력 새로 그리기
			$("#"+objId+" .calMonBody .calMonWeekRow .FirstLine  tbody").children().remove();
    		for (var i=0; i < 6; i++){
        		for (var j=0; j< 3; j++){
            		$("#"+objId+" .calMonBody .calMonWeekRow:eq("+i+") .FirstLine tbody").append($("<tr>"));
        			for (var k=0; k < 7; k++){
                		$("#"+objId+" .calMonBody .calMonWeekRow:eq("+i+") .FirstLine tbody tr:last").append($("<td>"));
        			}
        		}
    		}
    		
    		$("#"+objId+" .calMonWeekRow:eq(5)").show();
    		var calData = {};
    		calData["startDate"] = schday;
    	    for (var i = 0; i < 6; i++) {
    	        for (var j = 0; j < 7; j++) {
    	        	if (i==5 && j==0 && schedule_SetDateFormat(schday, '-') > eDate){ 	//마지막 주가 다음달로 넘어가면 숨김처리하기
    	        		$("#"+objId+" .calMonWeekRow:eq("+i+")").hide();
    	        		break;
    	        	}
    	        	if (schedule_SetDateFormat(schday, '-') < sDate ||			schedule_SetDateFormat(schday, '-') > eDate){
    	        		$("#"+objId+" .calMonWeekRow:eq("+i+") .monShcList td:eq("+j+")").addClass("disable");
    	        		$("#"+objId+" .calMonWeekRow:eq("+i+") .monShcList td:eq("+j+")").removeClass("calDate");
    	        	}
    	        	else{
    	        		$("#"+objId+" .calMonWeekRow:eq("+i+") .monShcList td:eq("+j+")").removeClass("disable");
    	        		$("#"+objId+" .calMonWeekRow:eq("+i+") .monShcList td:eq("+j+")").addClass("calDate");
    	        	}
    	        	//setDate
    	        	if (today == schedule_SetDateFormat(schday, '-'))
    		        	$("#"+objId+" .calMonWeekRow:eq("+i+") .monShcList td:eq("+j+")").addClass("setDate");
    	        	else
    	        		$("#"+objId+" .calMonWeekRow:eq("+i+") .monShcList td:eq("+j+")").removeClass("setDate");

    	        	$("#"+objId+" .calMonWeekRow:eq("+i+") .monShcList td:eq("+j+")").attr("title", schedule_SetDateFormat(schday, ''));
    	        	$("#"+objId+" .calMonWeekRow:eq("+i+") .monShcList td:eq("+j+")").removeClass("selDate").removeClass("Bg");//.removeClass("CalWork");
    	        	if (j > 0) $("#"+objId+" .calMonWeekRow:eq("+i+") .monShcList td:eq("+j+")").removeClass("tx_sun");

    	        	for(var k=0; k <3; k++){
	    	        	$("#"+objId+" .calMonWeekRow:eq("+i+") .FirstLine tr:eq("+k+") td:eq("+j+")").attr("id","td_"+schedule_SetDateFormat(schday, '')+"_"+k);
	    	        	$("#"+objId+" .calMonWeekRow:eq("+i+") .FirstLine tr:eq("+k+") td:eq("+j+")").text("");
    	        	}

    	        	$("#"+objId+" .calMonWeekRow:eq("+i+") .monShcList td:eq("+j+") strong").text(schedule_SetDateFormat(schday, '-').substring(8)).attr("title",schedule_SetDateFormat(schday, ''));
    	        	$("#"+objId+" .calMonWeekRow:eq("+i+") .monShcList td:eq("+j+")").attr("id","sum_"+schedule_SetDateFormat(schday, '')).data({"1F":"0","2F":"0","3F":"0"});
    	        	schday = schedule_AddDays(schday, 1);
    	        }
    	    }
    		calData["endDate"] = schedule_SetDateFormat(schday, '-');
    	    $(titleId).text(sDate.substring(0,7));
    		return calData;
    	},
    	getUTCTime:function(stndDate){
    		var today   =new Date(coviCmn.getDateFormat(stndDate));
//    		var today = new Date();
//	    	today.setUTCHours(0);
//	    	today.setUTCMinutes(0);
//	    	today.setUTCSeconds(0);
//	    	today.setUTCMilliseconds(0);
    	    return new Date(coviCmn.getDateFormat(stndDate,"-"));//+"T09:00:00.000Z");
//    		return today;
    	},
    	getGanttName:function(item,dateType ){
    		if (dateType == "D" || dateType == "W"){
	    		var startDate = collabUtil.getUTCTime(item.StartDate);
	    		var endDate   = collabUtil.getUTCTime(item.EndDate);
	    		
	    		var diff = schedule_GetDiffDates (startDate, endDate,"day");
	    		
	    	    return diff<2 && item.TaskName.length>20?item.TaskName.substring(0, 17)+"...":item.TaskName;
    		}else{
    			return item.TaskName;
    		}   
    	},
    	loadGantt:function(gantType,dateType, objId, jsonData, startdate, enddate, myTodo, filterList){
    	    var day = 1000 * 60 * 60 * 24;
    	    
    		var today   =collabUtil.getUTCTime(startdate);
    		var maxday  =collabUtil.getUTCTime(enddate) ;
    		maxday.setDate(maxday.getDate() + 1);
			
	    	$("#"+objId+" .gannt-container").empty().append($("<div>",{"id":"gannt_"+objId}));
	    	var data = [];
	    	var dataPlot = [];
	    	var categories = [];
	    	var htCat = {}
	    	if (filterList != null ){
		    	filterList.map( function( item,idx ){
					//var key = $(item).attr("id");
					if (myTodo  == 'Y'){
						categories.push(item=="W"? Common.getDic("lbl_Ready"):(item=="H"? Common.getDic("lbl_apv_hold"):(item=="C"? Common.getDic("lbl_apv_completed"):Common.getDic("lbl_goProcess"))));
			    		htCat[item]=idx;
					}	
					else{	
						data.push({"name" : item.SectionName, "id" : "s_"+item.SectionSeq
							,"start":0
							,"end":0
	    				});
			    		categories.push(item.SectionName);
			    		htCat[item.SectionSeq]=idx;
					}	
		    		
	    		});
	    	}	

	    	$("#"+objId+" .gannt-container").data(htCat);

	    	var yValue=0;
	    	jsonData.map( function( taskList,k ){
	    		taskList["list"].map( function( item,idx ){
			    		var startDate = collabUtil.getUTCTime(item.StartDate);
			    		var endDate   = collabUtil.getUTCTime(item.EndDate);
			    		
			    		var startday = startDate < today ? 0:schedule_GetDiffDates (today, startDate,"day");
			    		var endday  = item.StartDate==item.EndDate ? startday
			    					: schedule_GetDiffDates (today, endDate >= maxday ? maxday: endDate,"day")
		  				var aUsers = new Array();
						if (item.tmUser != null){
							aUsers = item.tmUser.split('|');
							if (aUsers.length>0){
								aUserInfo = aUsers[0].split('^');
							}	
						}	
						var y = myTodo  == 'Y'?htCat[item.TaskStatus]:htCat[item.SectionSeq];
						y = y ==undefined || y ==""? 0:y;
//						y+=0.5;
						var color= "#D9D9D9";
						var colorIndex;
						if (item.IsMile=="Y"){
							color="#04B153";
						}
						else{
							switch (item.ImpLevel){
							case "H":
								color = "#FF9775";
								break;
							case "M":
								color= "#6e5dc5";
								break;
							case "L":
								color= "#71BFFF";
								break;
							}
	    				}

						data.push({"name" : collabUtil.getGanttName(item, dateType), "id" : "t_"+item.TaskSeq
			    				,"start": today.getTime() + startday * day
			    				,"end": today.getTime() + (endday+1) * day
			    				,"y":y
			    				,"desc":schedule_SetDateFormat(item.StartDate,".")+"~"+schedule_SetDateFormat(item.EndDate,".")
			    				,"dependency": item.LinkTaskSeq!=""?"t_"+item.LinkTaskSeq:""
			    				,"parent": myTodo=='Y'?'':'s_'+item.SectionSeq
			    				,"completed":item.ProgRate/100
			    				,"milestone":item.IsMile=='Y'?true:false
			    				,"color": color
			    				,"taskSeq": 	item.TaskSeq
			    				,"linkTaskName":	item.LinkTaskName
			    				,"linkTaskSeq": 	item.LinkTaskSeq
			    				,"objId": 	objId
			    				,"UserCode":aUsers.length>0?aUserInfo[0]:""
			    				,"UserName":aUsers.length>0?aUserInfo[1]:""	
								,"ProgRate":item.ProgRate	
								,"Cat":myTodo  == 'Y'?item.TaskStatus:item.SectionSeq
			    				});
						
						if (item.IsMile=='Y'){
							dataPlot.push( {
		         	            value:  today.getTime() + (startday) * day,
		         	            zIndex: 5,
		         	            width: 2,
		         	            color: '#04B153'
							})
						}
			    	});
    		});    

	    	var gantConf = {time:{timezone:'asia/seoul'}
	    			,title:{text:$("#" + objId).closest('.cRContBottom').data("gant_sdate")+"~"+$("#" + objId).closest('.cRContBottom').data("gant_edate")}
	    			,tooltip: { outside: true	    		    }};     
	    	
	     	gantConf["plotOptions"] = {
         	    	gantt:{connectors:{
	 	     	            	dashStyle:'solid',
	 	     	            	enabled:true,
	 	     	            	lineWidth:2,
	 	     	            	},
 	     	            	centerInCategory:true,
 	     	            	chart:{styleMode:true}},
          	        series: {
          	            animation: false, // Do not animate dependency connectors
          	            allowPointSelect: true,
          	            tooltip: {
          	                headerFormat: '<b>{point.UserCode}</b><br>',
          	                pointFormat: '{point.UserName}[{point.ProgRate}%]<br>{point.name}<br>{point.desc}',
          					useHTML:true,
          					backgroundColor:'#ffffff'
          	            }
          	        }
          	    };
	     	//드래그 가능 조건
	     	if (myTodo  == 'Y' || $("#"+objId).data( "prjAdmin") == "Y"){	//관리자만 연결/이동 가능	
	     		gantConf["plotOptions"]["series"]["point"]= {
      	                events: {}//;select: collabUtil.selectChartPoint}
      	            };
	     		if (dateType == "D" || dateType == "W"){//일간/주간만 날짜이동 가능
		     		gantConf["plotOptions"]["series"]["point"]["events"]["drop"]= collabUtil.dropChartPoint;
		     		gantConf["plotOptions"]["series"]["dragDrop"]= {
		     				draggableX: true,
	       	                draggableY: true,
	       	                dragPrecisionX: day / 3 // Snap to eight hours
	      	            };
	     		}	
	     	}
	     	gantConf["series"]=[{type:'gantt',
	     		   allowPointSelect:true,
         		   name: objId,
         		   data:data,
				   dataLabels: [{enabled: true,
						         format: '<div class="chartTitle" style="width: 20px; height: 20px; overflow: hidden; border-radius: 50%; margin-left: -30px;border:solid 1px #A6A6A6">' +
						                '<span style="width: 20px; margin-left: -5px; margin-top: -2px"></span></div>',
						         useHTML: true,
						         align: 'left'},
				       {enabled: true,
				    	useHTML:true,
				    	align:'left',
				    	formatter: function () {//<p><strong>대근</strong></p>
				    		return '<span class="chartItem">'+(this.point.milestone == true?"":(this.point.UserCode&&(dateType=="W"||dateType=="D")?'<div class="user_img"><p><strong>'+this.point.UserName.substring(1,3)+'</strong></p></div>':''))
				    			+'<span class="gant" style="font-weight:bold;color:#000000">' + this.point.name+'</span></span>';}},
				    ],    
	     			
	     		}];
	     	var dataPlotBand = [];
     		if (dateType == "D" || dateType == "W" || dateType == "M"){//일간/주간인 경우 주말 표기
    			var diff = schedule_GetDiffDates (new Date(coviCmn.getDateFormat(startdate,"-")), new Date(coviCmn.getDateFormat(enddate,"-")),"day")+1;
	    		for (var i = 0 ; i < diff;i++){
	    			var plotDay = collabUtil.getUTCTime(schedule_SetDateFormat(schedule_AddDays(startdate, i),""));
	    			var weekOfDay = plotDay.getDay();

	    			if (weekOfDay == 6 || weekOfDay == 0){
			    		var startday = schedule_GetDiffDates (new Date(coviCmn.getDateFormat(startdate,"-")), plotDay, "day");
			    		dataPlotBand.push( {
		     	            from:  today.getTime() + (startday) * day,
		     	            to:  today.getTime() + (startday+1) * day,
		     	            color: '#ebebec'
						})
	    			}	
	    		}	
     		}	
	     	var gantxAsis ={min: today.getTime() ,
	         	      max: maxday.getTime(),
//	         	      alternateGridColor:'#ebebec',
	         	      tickInterval:  day,
	         	      plotLines: dataPlot,
	         	      plotBands: dataPlotBand,
	         	    };
	     	
	     	if (dateType == "W"){
		     	gantConf["xAxis"]=gantxAsis;
	     	}else{
		        gantConf["xAxis"]=[];
		        gantConf["xAxis"][0] = gantxAsis;
		        
	    	    switch (dateType){
	    	    	case "D":	//일간
		    	    	gantConf["xAxis"][0]["labels"]= {
	    	    				format:('{value:%d}') ,
			    	    	   	showEmpty: true};
		    	    	break;
		    	    case "M":	//월간
		    	    	gantConf["xAxis"][0]["tickInterval"]= day*7;
		    	    	gantConf["xAxis"][0]["labels"]= {
		    	 	    	   	format:('{value:%y.%m.%d}'),
	   	 	    	    	   	showEmpty: true};
			    	    break;
		    	    case "Q":	//분기
		    	    	gantConf["xAxis"][0]["tickInterval"]= day*30;
		    	    	gantConf["xAxis"][0]["labels"]= {
		    	 	    	   	format:('{value:%y.%m}'),
			    	    	   	showEmpty: true};
			    	    break;	
		    	    case "H":	//반기
		    	    	gantConf["xAxis"][0]["tickInterval"]= day*30;
		    	    	gantConf["xAxis"][0]["labels"]= {
		    	 	    	   	format:('{value:%y.%m}'),
			    	    	   	showEmpty: true};
			    	    break;	
		    	    case "Y":	//년
		    	    	gantConf["xAxis"][0]["tickInterval"]= day*30;
		    	    	gantConf["xAxis"][0]["labels"]= {
		    	 	    	   	format:('{value:%y.%m}'),
			    	    	   	showEmpty: true};
			    	    break;	
		    	    default:
		    	    	break;
	    	    } 
	     	}	 
	        
    		gantConf["yAxis"] = {
	         	      type: gantType == 'GANTN'?'treegrid':'category',
	         	      categories: categories,
	         	      min: 0,
	         	      max:  gantType == 'GANTN'?data.length-1:categories.length-1,
	         	    }
    		var chart = new Highcharts.ganttChart("gannt_"+objId, gantConf);
	   	},
	   	openProjectAllocPopup:function(taskSeq, isExport, callBack){
	 		var popupID	= "CollabProjectAllocPopup";
	 		var openerID	= "";
	 		var popupYN		= "N";
	 		var popupUrl	= "/groupware/collabTask/CollabProjectAllocPopup.do?"
	 						+ "&taskSeq="    + taskSeq
	 						+ "&isExport="    + isExport
	 						+ "&popupID="	 + popupID	
	 						+ "&openerID="	 + openerID	
	 						+ "&popupYN="	 + popupYN	
	 						+ "&callBackFunc="	+ callBack	;
			Common.open("", popupID, Common.getDic("btn_apv_AddTask"), popupUrl, "400", "500", "iframe", true, null, null, true);

 		},
	   	dropChartPoint:function(data){
	   	    event.preventDefault();

	   	    var chart = this.series.chart;
			var start = data.target.start 
			var end = 	data.target.end;
			var difference = end - start;
			
			var objId =chart.series[0].name;
			var htCat = $("#"+objId+" .gannt-container").data();

			var sectionSeq = "";
			for(var index in htCat){
				if (htCat[index] == data.target.y){
					sectionSeq =  index;
					break;
				}
			};

	   	    var prjType = objId.split("_")[0];
	   	    var prjSeq= objId.split("_")[1];

	   		var taskData = {"prjType":prjType
	   			,"prjSeq":prjSeq
	   			,"taskSeq":data.target.taskSeq
				,"startDate": new Date(start).toISOString().substring(0,10).replace(/-/g,'')
				,"endDate": new Date(end).toISOString().substring(0,10).replace(/-/g,'')
			}

//	   		category
	   		if ($("#"+objId).closest('.cRContBottom').data("dataView") == 'GANT' && data.target.Cat != sectionSeq){
		   		if (objId != "todo"){
		   			taskData["sectionSeq"]=sectionSeq
		   			taskData["TODO"]="N";
		   		}
		   		else{
		   			taskData["taskStatus"]=sectionSeq;
		   			taskData["TODO"]="Y";
		   		}
	   		}	
	   		
			$.ajax({
				type:"POST",
				data: taskData,
				url:"/groupware/collabTask/changeProjectTaskDate.do",
				success:function (data) {
					if(data.status == "SUCCESS"){
				        //collabMain.getMyTask(objId, aData);
						$('#'+objId+' .btnRefresh').trigger("click");
					}
					else{
						Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"); //	ì¤ë¥ê° ë°ìíìµëë¤. ê´ë¦¬ììê² ë¬¸ìë°ëëë¤
					}
				},
				error:function (request,status,error){
					Common.Error("<spring:message code='Cache.msg_ErrorOccurred' />"+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
				}
			});
			
	   	}
	   	,StringBuffer : function(){
	   		var buf = "";
	   		this.append = function(text){
	   			buf = buf + text;
	   		};
	   		this.toString = function(){
	   			return buf;
	   		}
	   	}
	   	,getTaskStatus:function(item){
    		var className;
    		var text;
    		if (item.TaskName == null ) return "";
    		switch (item.TaskStatus)
    		{
    			case "H":
    				className = "bs_state01";
    				text = "보류";
    				break;
    			case "P":
    				className = "bs_state03";
    				text = "진행";
    				break;
    			case "C":
    				className = "bs_state04";
    				text = "완료";
    				break;
				default:""
					className = "bs_state02";
					text = "대기";
					break;
    				
    		}
    		return "<span class='bs_state " + className + "'>" +text+  "</span>"+item.TaskName ;
   		},
   		getPageStr:function(page, evenStr){
			var pageStr = "";
   			if(page != null) {
				pageStr += "<input type='button' class='AXPaging_begin' onclick=\""+evenStr+"('F','" + (page.beginPage) + "');\">";
				pageStr += "<input type='button' class='AXPaging_prev' onclick=\""+evenStr+"('P','" + (page.beforePage) + "');\")>";

				for (var i = page.startPage; i <= page.endPage; i++) {
					pageStr += "<input type='button' value='" + (i) + "' onclick=\""+evenStr+"('G','" + (i) + "');\" class='AXPaging";
					if (page.page == (i)) {
						pageStr += " Blue";
					}
					pageStr += "'>";
				}
				pageStr += "<input type='button' class='AXPaging_next'  onclick=\""+evenStr+"('N','" + (page.nextPage) + "');\">";
				pageStr += "<input type='button' class='AXPaging_end'  onclick=\""+evenStr+"('L','" + (page.lastPage) + "');\">";
			} 
   			return pageStr;
   		},
   		getNoList:function(colspan){
   			if (colspan == undefined) colspan = 7;

   			var obj = $("<tr>",{"class":"gridBodyTr gridBodyTr_0 line0"})
   			.append($("<td>",{"class":"bodyTd bodyTd_0 bodyTdr_0","style":"vertical-align:middle;text-align: center;","text":Common.getDic("msg_ComNoData"),"colspan":colspan}))
			return obj;

   		},
   		getNoData:function(sTitle){
   			var obj =  $("<div>",{"class":"nodata_type03"})
			.append($("<span>",{"class":"no_icon no_icon03"}))
			.append($("<p>",{"text": Common.getDic("msg_Registered") + " " + sTitle + Common.getDic("msg_DonTHave") })); //등록된 sTitle (이)가 없습니다.
			return obj;
   		},
   		checkAll:function(trgObj, chkFlag ){
   			trgObj.find("input:checkbox").each(function() {
				$(this).prop("checked", chkFlag);
			});
   		},
   		goTaskDelete:function(cardData, objId){
			Common.Confirm( Common.getDic("msg_RUDelete"), "Confirmation Dialog", function (confirmResult) {
        		if (confirmResult) {
                	$.ajax({
                		type:"POST",
                		data:{
                			  "taskSeq"		: cardData.taskSeq
                			, "parentKey"	: cardData.parentKey
                			, "objectID"	: cardData.objectID
                			, "objectType"	: cardData.objectType
                		},
                		url:"/groupware/collabTask/deleteTask.do",
                		success:function (data) {
                			if(data.status == "SUCCESS"){
								if(opener === null) {
									parent.$("#rightmenu").removeClass("active");
									parent.$('.cRContCollabo_sub:visible .btnRefresh').trigger('click');
								} else {
									opener.$('.cRContCollabo_sub:visible .btnRefresh').trigger('click');
									Common.Close();
								}
                			}
                			else{
                				Common.Error(Common.getDic("msg_ErrorOccurred")+data); //	오류가 발생했습니다. 관리자에게 문의바랍니다
                			}
                		},
                		error:function (request,status,error){
                			Common.Error(Common.getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
                		}
                	});
	        	}
        	});

   		},
   		goTaskCopy:function(cardData, callBackFunc){
			var popupID	= "CollabTaskCopyPopup";
			var popupTit	= "["+cardData.taskName + "] "+Common.getDic("ACC_btn_copy");//"<spring:message code='Cache.lbl_app_approval_extention' />";
			var popupYN		= "N";

			var popupUrl	= "/groupware/collabTask/CollabTaskCopyPopup.do?"
							+ "&taskSeq="       + cardData.taskSeq
							+ "&popupID="		+ popupID	
							+ "&objId="			+ cardData.objId
							+ "&popupYN="		+ popupYN	
							+ "&callBackFunc="	+ callBackFunc	;
			Common.open("", popupID, popupTit, popupUrl, "350px", "160px", "iframe", true, null, null, true);

   		},
   	    goTaskModify:function(cardData, callBackFunc){	//카드수정
   	 		switch(cardData.objectType){
   		 		case "EVENT":
   					$.ajax({
   						url: "/groupware/schedule/getScheduleDateID.do",
   						type: "POST",
   						data: {
   							  "eventID"	: cardData.objectID
   							, "sDate"	: cardData.StartDate
   							, "eDate"	: cardData.EndDate
   						},
   						async: false,
   						success: function(data){
   							if(data.status === "SUCCESS"){
   								Common.Confirm(Common.getDic("msg_closePopupMoveToScheduleModify"), "Confirm", function(result){ // [확인] 버튼 클릭 시 해당 팝업이 닫히면서 일정 수정 페이지로 이동합니다.
   									if(result){
   										var url = String.format("/groupware/layout/schedule_DetailWrite.do?CLSYS=schedule&CLMD=user&CLBIZ=Schedule&eventID={0}&dateID={1}", cardData.objectID, data.dateID);
   										window.open(url);
   										window.close();
   									}
   								});
   							}else{
   								Common.Warning(data.message);
   							}
   						},
   						error: function(response, status, error){
   							CFN_ErrorAjax("/groupware/schedule/getScheduleDateID.do", response, status, error);
   						}
   					});
   		 			break;
   		 		case "SURVEY":
   					var popupID		= "CollabSurveyEditPopup";
   					var popupTit	= Common.getDic("lbl_Profile_Questions") + " " + Common.getDic("lbl_Edit"); // 설문 수정
   					var popupUrl	= "/groupware/survey/goSurveyCollabWritePopup.do?CLSYS=survey&CLMD=user&CLBIZ=Survey"
   									+ "&listType=modify&reqType=edit"
   									+ "&surveyId=" + cardData.objectID
   									+ "&prjSeq=" + cardData.prjSeq
   									+ "&prjType=" + cardData.prjType
   									;
   					
   					if(parent.$("#rightmenu").hasClass("active") == true ){
						parent.$("#rightmenu").removeClass("active");
						parent.Common.open("", popupID, popupTit, popupUrl, "1000px", "600px", "iframe", true, null, null, true);
					} else {
						Common.open("", popupID, popupTit, popupUrl, "1000px", "600px", "iframe", true, null, null, true);
					}
   					break;
   		 		default:
					collabUtil.openTaskAddPopup("CollabTaskSavePopup", callBackFunc, cardData.taskSeq, cardData.prjType, cardData.prjSeq, cardData.sectionSeq, cardData.prjName, cardData.sectionName, cardData.popup)//업무 상세화면
   				}
   	    },
   		getFileClass:function(ext){
   			switch(ext){
   			case "ppt":
   			case "pptx":
   				icon_class = "ic_ppt";
   				break;
   			case "xls":
   			case "xlsx":
   			case "xlsm":
   			case "xlsb":
   			case "xlt":
   			case "xltx":
   			case "xltxm":
   			case "xla":
   			case "xlam":
   				icon_class = "ic_xls";
   				break;
   			case "doc":
   			case "docx":
   				icon_class = "ic_word";
   				break;
   			case "pdf":
   				icon_class = "ic_pdf";
   				break;
   			case "zip":
   			case "tar":
   			case "gz":
   			case "7z":
   				icon_class = "ic_zip";
   				break;
   			default:
   				icon_class = "ic_etc";
				break;
   			}
			return icon_class;
   		},
		formatManager:function (mmUser){
			if (mmUser== null || mmUser == "") return "";
			var str=mmUser.split("|");
			var ret = mmUser;
			if (str.length>0) {
				var usrs = str[0].split("^");
				if (usrs.length>0) ret = usrs[1]+ (str.length>1?' 외'+(str.length-1):'');
			}
			return ret;
		},
		getDeptList:function(obj, defVal, aSync, bAll, bStep){
			//$("#schList")
			if (aSync == null) aSync=true;
			$.ajax({
				url : "/groupware/collab/getDeptList.do",
				type: "POST",
				async:aSync,
				dataType : 'json',
				success:function (data) {
					var subDeptList = data.deptList;
					var whole = Common.getDic("lbl_Whole");
					var subDeptOption = "";		
					if (bAll == undefined || bAll == true) subDeptOption = "<option value=''>"+whole+"</option>";		//전체
					for(var i=0;i<subDeptList.length;i++){

						subDeptOption += "<option value='"+(bStep==true?subDeptList[i].GroupPath:subDeptList[i].GroupCode)+"'>";
						var SortDepth = subDeptList[i].SortDepth;
						for(var j=1;j<SortDepth;j++) {
							subDeptOption += "";
						}
						subDeptOption += CFN_GetDicInfo(subDeptList[i].MultiDisPlayName)+"</option>";
					}

					obj.html(subDeptOption);
					if (defVal != ''){
						obj.val(defVal);
					}
				},
				error:function (error){
					//CFN_ErrorAjax("/groupware/layout/attendance_AttendanceBaseInfo.do", response, status, error);
				}
			});
		},
		openChannel:function(roomId){
			var channelServer = Common.getBaseConfig("eumServerUrl");
			var channelDir = "/client/nw/channel/"+roomId;
			var csjtk = encodeURIComponent(key);
			var channelURL = channelServer+"/manager/na/sso/gate.do?CSJTK="+csjtk+"&dir="+encodeURIComponent(channelDir);

			var specs = "left=10,top=10,width=1050,height=900";
			specs += ",toolbar=no,menubar=no,status=no,scrollbars=no,resizable=no";
			window.open(channelURL,"_blalk", specs);
		},
		leftChange : function(PrjSeq, prjStatus, orgStatus, prjName){	//좌측메뉴 변경
			
			//var leftMenuTmp = $("#list_P_" + PrjSeq, parent.document).closest('div').html();
			
			if($("#list_P_" + PrjSeq, parent.document).closest('.selOnOffBoxChk').children().length == 1){
				$("#list_P_" + PrjSeq, parent.document).closest('.selOnOffBoxChk').attr("class", "selOnOffBoxChk type02 boxList");
				$("#list_P_" + PrjSeq, parent.document).closest('.selOnOffBoxChk').prev().children("a").removeClass("active");
			}
			$("#list_P_" + PrjSeq, parent.document).closest('div').remove();
			
			//$("#prjList"+prjStatus, parent.document).append("<div>" + leftMenuTmp + "</div>");
			$("#prjList"+prjStatus, parent.document).append(
				$("<div>").append(
					$("<a>", {"class": "sub", "id":"list_P_" + PrjSeq}).data({
						"prjSeq": PrjSeq,
						"prjType": prjStatus,
						"prjName": prjName
					}).attr("load","Y").attr("data-type","P").append(
						$("<span>").append(prjName)
					)
				)
			);
			$("#prjList"+prjStatus, parent.document).addClass("active");
			$("#prjList"+prjStatus, parent.document).closest('li').find(".btnOnOff").addClass("active");

    	},
		btnFavEvent:function(objId, prjSeq, obj){	//즐겨찾기
			$.ajax({
		    		type:"POST",
		    		data:{"prjSeq":  prjSeq, "isFlag":$(obj).hasClass("active")},
		    		url:"/groupware/collabProject/saveProjectFavorite.do",
		    		success:function (data) {
		    			if(data.status == "SUCCESS"){
							if(objId == 'collabo_popup_wrap'){	// 팝업에서 실행시
								$("#P_"+prjSeq+" #btnFav", parent.document).toggleClass("active");
							}else{
								$("#"+objId+" .btn_coStar").toggleClass("active");
							}
							
		    				parent.collabMenu.getUserMenu();
		    			}
		    			else{
		    				Common.Error(Common.getDic("msg_ErrorOccurred")+data); //	오류가 발생했습니다. 관리자에게 문의바랍니다
		    			}
		    		},
		    		error:function (request,status,error){
		    			Common.Error(Common.getDic("msg_ErrorOccurred")+"code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error)
		    		}
		    	});
		},
		openProjectAlarmPopup:function(){	//프로젝트별 알림설정 팝업
			var popupID	= "CollabProjectAlarmPopup";
			var openerID	= "";
			var popupTit	=  Common.getDic("lbl_Project") + "별 알림설정  ";		//프로젝트
			var popupYN		= "Y";
			
	 		var popupUrl	= "/groupware/collabProject/CollabProjectAlarmPopup.do?"
	 						+ "popupID="		+ popupID	
							+ "&openerID="		+ openerID	
	 						+ "&popupYN="		+ popupYN ;
	 		
	 		Common.open("", popupID, popupTit, popupUrl, "600px", "500px", "iframe", true, null, null, true);
      },
		openClosingAlarmPopup:function(){	//프로젝트별 알림설정 팝업
			var popupID	= "CollabClosingAlarmPopup";
			var openerID	= "";
			var popupTit	=  "상세 설정";		//
			var popupYN		= "Y";
			
	 		var popupUrl	= "/groupware/collabProject/CollabClosingAlarmPopup.do?"
	 						+ "popupID="		+ popupID	
							+ "&openerID="		+ openerID	
	 						+ "&popupYN="		+ popupYN ;
	 		
	 		Common.open("", popupID, popupTit, popupUrl, "700px", "400px", "iframe", true, null, null, true);
      },
		openSlidingPopup:function(popupUrl){
			$("#rightmenu").addClass("active");
			
			var html = '<iframe id="right_if" class="bgiframe" frameborder="0" src="' + popupUrl + '" style="display:block;position:relative;width:100%;" scrolling = "auto"/>';
			$("#rightmenu").html(html);
			
			if ($("#right_if").length > 0)
            	$("#right_if").css("height", "100%");
      },
		openApprovalListPopup:function(taskSeq, svcType){	//관련결제 찾기 팝업
			var popupID	= "CollabApprovalListPopup";
			var openerID	= "";
			var popupTit	= "관련결재 찾기";		//
			var popupYN		= "Y";
			
	 		var popupUrl	= "/groupware/collabProject/CollabApprovalListPopup.do?"
	 						+ "popupID="		+ popupID	
							+ "&openerID="		+ openerID	
	 						+ "&popupYN="		+ popupYN ;
	 		if (svcType == "PROJECT"){
	 			popupUrl += "&PrjSeq="		+ taskSeq
	 					  + "&svcType="	+ svcType;
	 		}else{
	 			popupUrl += "&taskSeq="		+ taskSeq
						  + "&PrjSeq="	+ taskMapData.PrjSeq 
						  + "&PrjType="	+ taskMapData.PrjType;;
	 			
	 		}
	 		
	 		Common.open("", popupID, popupTit, popupUrl, "500px", "520px", "iframe", true, null, null, true);
      }

		// 업무 > 관련업무 추가 관련 팝업.
		, openTaskLinkPopup : function(pType, pSeq) {
			var popupID = "CollabTaskLinkPopup";
			var openerID = "";
			var popupTit = Common.getDic("lbl_linkTask"); 	// lbl_linkTask : 관련업무
			var popupYN = "Y";
			let pTaskSeq = CFN_GetQueryString("taskSeq");
			// 기존 칸반의 관련업무 팝업 콜백(callbackTaskLink)을 간트차트에서 가져다쓰며 오류 발생. 칸반 조건이 더 상세해 칸반쪽 콜백을 변경 처리(23.04.07).
			let pCallBackFunc = "callbackTaskLinkKanban";
			var popupUrl = "/groupware/collabTask/CollabTaskLinkPopup.do?pType="+pType+"&pSeq="+pSeq+"&pTaskSeq="+pTaskSeq+"&callBackFunc="+pCallBackFunc;
			
			parent.Common.open("", "collabTaskSavePopup", Common.getDic("lbl_linkTask"), popupUrl, "600px", "500px", "iframe", true, null, null, true);
		}
		// 업무 추가시 담당자 자동완성 (부서명 표시)
		, attachDeptEventAutoTags : function(objId, params){
			var autoTagsUrl = "";
			if (params == undefined || params["prjType"] == "M" || params["prjType"] == "undefined" || params["prjType"] == ""){
				autoTagsUrl = '/covicore/control/getAllUserGroupAutoTagList.do';
				coviCtrl.setUserWithDeptAutoTags(objId, autoTagsUrl, collabUtil.MultiDeptAutoCommInfos);	//자동완성
			}	
			else{
				autoTagsUrl = String.format("/groupware/collabProject/getProjectMemberList.do?prjSeq={0}&prjType={1}", params["prjSeq"], params["prjType"]);
				coviCtrl.setUserWithDeptAutoTags(objId, autoTagsUrl, collabUtil.MultiDeptAutoInfos);	//자동완성
			}
		},
		 MultiDeptAutoCommInfos : {
				labelKey : 'Name',
				valueKey : 'Code',
				addInfoKey : 'DeptName',
				minLength : 1,
				useEnter : false,
				multiselect : true,
				select : function(event, ui) {
					var id = $(document.activeElement).attr('id');
					var item = ui.item;
					var type = "UR" ;
					
					var cloned = collabUtil.drawProfile({"code":item.Code,"type":type,"DisplayName":item.Name, "data":item}, true);
					$(this).before(cloned);
	
			    	ui.item.value = ''; // 선택 후 input에 value값이 들어가는 문제가 있어 빈값 처리
				}		
	   	 },
		 MultiDeptAutoInfos : {
    			labelKey : 'DisplayName',
    			valueKey : 'UserCode',
				addInfoKey : 'DeptName',
    			minLength : 1,
    			useEnter : false,
    			multiselect : true,
    			select : function(event, ui) {
    				var id = $(document.activeElement).attr('id');
    				var item = ui.item;
    				var type = "UR" ;

    				var cloned = collabUtil.drawProfile({"code":item.UserCode,"type":type,"DisplayName":item.label, "data":item}, true);
    				$(this).before(cloned);

    		    	ui.item.value = ''; // 선택 후 input에 value값이 들어가는 문제가 있어 빈값 처리
    			}		
    	}
}