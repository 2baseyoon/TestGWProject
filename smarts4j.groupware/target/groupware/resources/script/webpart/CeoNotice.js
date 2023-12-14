/**
 * approvalBox - 전자결재 - 결재함
 */
var ceoNotice ={
		webpartType: '', 
		
		init: function (data,ext){
			$.each( data[0], function(index, value) {
				$("#ceoNotice ul").append('<li >'+
					'	<a href="#"><span class="CEOBbullet"></span><span class="CEOBtitle"  onclick=\'ceoNotice.goViewPopup('+value.MenuID+','+value.Version+','+value.FolderID+','+value.MessageID+')\'>'+value.Subject+'</span><span class="CEOBdate">'+value.CreateDate.substring(5,10).replace('-','.')+'</span></a>'+
					'</li>');
			});
		},
		goViewPopup: function( pMenuID, pVersion, pFolderID, pMessageID){
			var url = String.format("/groupware/board/goBoardViewPopup.do?CLBIZ={0}&menuID={1}&version={2}&folderID={3}&messageID={4}&viewType=Popup", "Board", pMenuID, pVersion, pFolderID, pMessageID);
			parent.Common.open("", "boardViewPop", "<spring:message code='Cache.lbl_DetailView'/>", url, "1080px", "600px", "iframe", true, null, null, true);
		},
}