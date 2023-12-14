<%@page import="egovframework.baseframework.util.PropertiesUtil,egovframework.coviframework.util.ACLHelper,egovframework.baseframework.util.json.JSONSerializer,org.apache.commons.lang3.StringUtils,egovframework.baseframework.util.SessionHelper"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<body>
<div class="cRConTop titType AtnTop">
	<h2 class="title"></h2>
</div>
<div class="cRContBottom mScrollVH" id=confSchedule>
	<div id="topitembar03" class="inPerView type02 sa04 active">
		<div>
			<div class="selectCalView" id="scheduleType"> 
				<div class="chkStyle10"><input type="checkbox" class="check_class" id="chk_Total" value="Total" checked=""><label for="chk_Total"><span class="s_check"></span><spring:message code='Cache.lbl_ConsolidationSchedule'/></label> </div> <!-- 통합 일정 -->	
				<div class="chkStyle10"><input type="checkbox" class="check_class" id="chk_Cafe" value="Cafe"><label for="chk_Cafe"><span class="s_check"></span><spring:message code='Cache.lbl_CommunitySchedule'/></label> </div> <!-- 커뮤니티 일정 -->
				<div class="chkStyle10"><input type="checkbox" class="check_class" id="chk_Theme" value="Theme"><label for="chk_Theme"><span class="s_check"></span><spring:message code='Cache.lbl_schedule_theme'/></label> </div> <!-- 테마일정 -->	
			</div>	
			<div class="selectCalView"> 
				<select name="" class="selectType02" id="selectSearchType">
					<option value="MultiDisplayName" selected="selected"><spring:message code='Cache.lbl_ScheduleNm' /></option> <!-- 일정명 -->
					<option value="OwnerName"><spring:message code='Cache.lbl_Operator' /></option> <!-- 운영자 -->
					<option value="RegisterName"><spring:message code='Cache.lbl_Register' /></option> <!-- 등록자 -->
				</select>
				<input type="text" id="searchValue" >
			</div>	
			<div class="dateSel type02">
				<div class="chkStyle10"><input type="checkbox" class="" id="chk_IsAll" value="Y" ><label for="chk_IsAll"><span class="s_check"></span><spring:message code='Cache.btn_All' /></label> </div>
				<a href="#" class="btnTypeDefault btnSearchBlue nonHover" id="btnSearch" ><spring:message code="Cache.btn_search"/></a>
			</div>
		</div>	
	</div>
    <div class="sadminContent">
    	<div class="sadminMTopCont">
			<div class="pagingType02 buttonStyleBoxLeft">
				<div  id="divBtnSchedule">
					<a class="btnTypeDefault" id="btnAddSchedule"><spring:message code='Cache.btn_Add' /></a>
					<a class="btnTypeDefault" id="btnDelSchedule" ><spring:message code='Cache.btn_delete' /></a>
				</div>	
			</div>
			<div class="buttonStyleBoxRight">
				<button class="btnRefresh" type="button" href="#"  id="btnRefresh"></button>
			</div>
		</div>	
		<!-- 폴더 Grid 리스트 -->
		<div id="folderGrid" class="tblList tblCont"></div>
	</div>
</div>	
</body>

<script type="text/javascript">
var confSchedule = {
		folderGrid :new coviTree(),		//폴더 Grid
		domainID :confMenu.domainId,
		folderID : '', 
		scheduleHeader :[{key:'chk', label:'chk', width:'20', align:'center', formatter:'checkbox'},
		                 {key: "MultiDisplayName",			// 컬럼에 매치될 item 의 키
								indent: true,				// 들여쓰기 여부
								label: '<spring:message code="Cache.lbl_ScheduleNm"/>',
								width: "170",
								align: "left",
								getIconClass: function(){	// indent 속성 정의된 대상에 아이콘을 지정 가능
									var sRetIcon;
				   					if (this.item.FolderType=="Root" || this.item.FolderType=="Folder")
				   						sRetIcon = "ic_folder ";
				   					else {
				   						sRetIcon = "ic_file ";
				   						if (this.item.IsContents == "Y") sRetIcon += "icon20";
				   					}	
									 if (this.item.IsUse == "N" || this.item.IsDisplay == "N") sRetIcon += "icon02";
				   					return sRetIcon;
								},
								formatter:function(){
									return '<a href="#" onclick="confSchedule.editFolderPopup(\'U\',\'' + this.item.FolderID + '\')">' + this.item.MultiDisplayName + '</a>';},				// 일정명
							},
	                 	  {key:'DefaultColor', label:'<spring:message code="Cache.lbl_DefaultColor"/>', width:'80', align:'center',					// 기본 컬러
								formatter:function(){
									var htmlStr = "";
									if(this.item.DefaultColor != "" && this.item.DefaultColor != undefined){
										htmlStr += "<span id='pDefaultColor' style='background-color:"+this.item.DefaultColor+";float: left;display: inline;width: 80px;height: 25px;'>";
										htmlStr += "</span>";
									}
									return htmlStr;
								}
						   },
		                  {key:'OwnerName', label:'<spring:message code="Cache.lbl_Operator"/>', width:'100', align:'center'},						// 운영자
		                  {key:'RegisterName', label:'<spring:message code="Cache.lbl_Register"/>', width:'100', align:'center'},					// 등록자
		                  {key:'IsDisplay', label:'<spring:message code="Cache.lbl_Display"/>', width:'60', align:'center',
		                	  formatter: function() {
				        			return confSchedule.formatSwitch(this); 
				        		}  
		                  },	
		                  {key:'IsUse', label:'<spring:message code="Cache.lbl_selUse"/>', width:'60', align:'center',
		                	  formatter: function() {
				        			return confSchedule.formatSwitch(this); 
				        		}  
		                  },								// 사용
		                  {key:'SortKey', label:'<spring:message code="Cache.lbl_Sort"/>', width:'50', align:'center', sort:'asc'},					// 정렬
		                  {key:'RegistDate', label:'<spring:message code="Cache.lbl_RegistDateHour"/>' + Common.getSession("UR_TimeZoneDisplay"), width:'100', align:'center', 
		                	  formatter: function(){
		                		  return CFN_TransLocalTime(this.item.RegistDate);
		                	  }
		                  },{key:'', label:"<spring:message code='Cache.lbl_action'/>", width:'50', align:'left', display:true, sort:false,
		  					formatter:function(){
								var html = '';
								if (this.item.FolderType=="Folder") {
									html += '<a href="javascript:;" class="btnTypeDefault btnPlusAdd" onclick="confSchedule.editFolderPopup(\'I\',\'' + this.item.FolderID + '\');"><spring:message code="Cache.btn_apv_Person"/></a>';
								}
								return html;
							}
						}	],
		initContent:function (){
			Common.getBaseConfigList(["ScheduleMenuID"]);
			confSchedule.folderGrid._targetID="folderGrid"
			confSchedule.folderGrid.setConfig( {
				theme: "AXTree_none",
				targetID : "folderGrid",
				height:"auto",
				colGroup:confSchedule.scheduleHeader,
				showConnectionLine: true,	// 점선 여부
				persistExpanded: false,		// 쿠키를 이용해서 트리의 확장된 상태를 유지 여부
				persistSelected: false,		// 쿠키를 이용해서 트리의 선택된 상태를 유지 여부
				colHead: {
					display: true
				},
				fitToWidth: true,			// 너비에 자동 맞춤
				body: {onexpand:function(idx, item){ //[Function] 트리 아이템 확장 이벤트 콜백함수
			            if (item.FolderType =="Folder" && item.haveChild=="Y" && item.__subTreeLength == 0){
			            	$.ajax({
			            		url: "/groupware/manage/schedule/selectFolderTreeList.do",
			    				type: "POST",
			    				data: {
			    			    	"MenuID":coviCmn.configMap["ScheduleMenuID"],
			    					"FolderID":item.FolderID,
			    					"lang":lang,
			    					"DomainID": confMenu.domainId},
			    				async: false,
			    				success: function(data){
			    					confSchedule.folderGrid.appendTree(idx,item, data.list);
			    				},
			    				error: function(response, status, error){
			    					CFN_ErrorAjax("/groupware/admin/selectFolderTreeData.do", response, status, error);
			    				}
			    			});
			            }
				       }
				    }});
			this.setFolderData();
			
			$("#scheduleFolder").click(function () {//폴더 새로고침
				confSchedule.setFolderData();
			});

			$("#confSchedule .check_class").on('click', function(){
				$('#confSchedule .check_class').not(this).prop("checked", false);
				confSchedule.setFolderData();
			});
			
			//검색
			$("#searchValue").on( 'keydown',function(){
				if(event.keyCode=="13"){
					confSchedule.setFolderData();
	
				}
			});	
			
			$("#btnSearch").on( 'click',function(){
				confSchedule.setFolderData();
			});	
			
			//일정추가
			$("#btnAddSchedule").on( 'click',function(){
				confSchedule.editFolderPopup('I','');
			});
			//일정삭제
			$("#btnDelSchedule").on( 'click',function(){
				confSchedule.deleteScheduleData('');
			});

			$("#btnRefresh").on("click",function(){
				confSchedule.setFolderData();
			});
		},
		setFolderData:function(){
			var selectSearchType = $("#selectSearchType").val();	
			var searchValue = $("#searchValue").val();
			var folderType = $('#confSchedule .check_class:checked').val();
			$.ajax({
				url: "/groupware/manage/schedule/selectFolderTreeList.do",
				type: "POST",
				data: {
			    	"MenuID":coviCmn.configMap["ScheduleMenuID"],
					"FolderType":"Schedule."+$('#confSchedule .check_class:checked').val(),
					"selectSearchType":selectSearchType,
					"searchValue":searchValue,
					"lang":lang,
					"pageSize":"9999",
					"DomainID": confMenu.domainId,
					"isAll":$("#chk_IsAll").prop("checked")?"Y":"N"},
				async: false,
				success: function(data){
					confSchedule.folderGrid.setList(data.list);
					var gridObj = confSchedule.folderGrid;
					var targetID = gridObj.config.targetID;
					$( gridObj.list ).each( function(idx, v) {
						if (v["hasChild"]!="0"){//bodyNodeIndent
							$("#folderGrid .AXTreeBody table tbody tr:eq("+idx+") .bodyNodeIndent").show()
						}
					});
				},
				error: function(response, status, error){
					CFN_ErrorAjax("/groupware/admin/selectFolderTreeData.do", response, status, error);
				}
			});
		},
		editFolderPopup:function(mode, folderID){
			var scheduleType = $('#confSchedule .check_class:checked').val();
			Common.open("","updateConfig","<spring:message code='Cache.lbl_schedule_title' />","/groupware/manage/schedule/adminFolderPopup.do?mode="+mode+"&FolderID="+folderID+"&ScheduleType="+scheduleType+"&DomainID="+confSchedule.domainID,"650px","550px","iframe",true,null,null,true);
			
		},
		deleteScheduleData:function(){
			var checkList =this.folderGrid.getCheckedList(0); 
			var isIncludeFolder = false;
			
			if(checkList.length > 0){
				//폴더가 있을 경우 하위데이터 모두 삭제할지 확인
				$(checkList).each(function(){
					if(this.FolderType == "Folder"){
						isIncludeFolder = true;
					}
				});
				
				var msg = "<spring:message code='Cache.ACC_msg_ckDelete'/>";
				if(isIncludeFolder){
					 msg = "<spring:message code='Cache.msg_DeleteFailFDQ'/>";
				}
				
				Common.Confirm("<spring:message code='Cache.msg_DeleteFailFDQ'/>", "Confirm", function(result){
					if(result){
						$.ajax({
						    url: "/groupware/manage/schedule/deleteAdminFolderData.do",
						    type: "POST",
						    data: {
								"folderData":JSON.stringify(checkList)
							},
						    success: function (res) {
						    	if(res.status == "SUCCESS"){
						            Common.Inform("<spring:message code='Cache.msg_Deleted'/>", "Information", function(){
						            	confSchedule.setFolderData();
						            });
						    	}else{
						    		Common.Error("<spring:message code='Cache.msg_apv_030'/>");		// 오류가 발생했습니다.
						    	}
					        },
					        error:function(response, status, error){
								CFN_ErrorAjax("/groupware/schedule/deleteAdminFolderData.do", response, status, error);
							}
						});						
					}
				});
			}else{
				Common.Warning("<spring:message code='Cache.msg_270'/>");		//삭제할 대상이 없습니다.
			}
		},
		updateFlag: function(pParam, pFlagValue, pTarget){
			let param = JSON.parse(pParam);
			let folderID = param.folderID;
			let flagKey = param.columnName;

		 	if(folderID){
				$.ajax({
					type: "POST",
					url: "/groupware/manage/schedule/updateScheduleFlag.do",
					data: {
						"folderID": folderID,
						"flagKey": flagKey, // IsUse, IsDisplay의 이름으로 DB스크립트 컬럼 지정
						"flagValue": pFlagValue
					},
					success: function(data){
						if(data.status === 'SUCCESS'){
							Common.Indicator(Common.getDic("msg_37"), null, 1000);			// 저장되었습니다.
						}else{
							Common.Warning("<spring:message code='Cache.msg_apv_030'/>"); // 오류가 발생헸습니다.
							
							if (pFlagValue == 'Y') {
								$("#switch_"+folderID+"_"+flagKey).val($("#switch_"+folderID+"_"+flagKey).attr("off_value"));
								$(pTarget).removeClass("on");
							} else {
								$("#switch_"+folderID+"_"+flagKey).val($("#switch_"+folderID+"_"+flagKey).attr("on_value"));
								$(pTarget).addClass("on");
							}
						}
					},
					error: function(response, status, error){
						CFN_ErrorAjax("/groupware/manage/schedule/updateScheduleFlag.do", response, status, error);
					}
				});
			}
		},
		formatSwitch: function (pObj) {
			var param = pObj.item;
			param.on = 'Y'; param.off = 'N';
			param.defVal = param[pObj.key];
			param.retVal = { folderID: param.FolderID, columnName: pObj.key };
			return coviCmn.getCoviSwitch('switch_'+param.FolderID+'_'+ pObj.key, param, 'confSchedule.updateFlag');
		}
}

$(document).ready(function(){
	confSchedule.initContent();
});
	

</script>