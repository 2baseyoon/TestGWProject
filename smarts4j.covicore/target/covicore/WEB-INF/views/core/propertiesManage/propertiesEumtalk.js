var EumtalkGrid = new coviGrid();


const pE2 = document.querySelector('.log');
const eumtalkFile = document.querySelector('.eumtalkFile');
const eumtalkPreview = document.querySelector('.eumtalkPreview');

/**
const eumtalkFileTypes = [
    'hosts',
	'httpd.conf',
	'mod_jk.conf',
	'uri.properties',
	'workers.properties',
	'httpd-vhosts.conf',
	'httpd-ssl.conf',
	'server.xml',
	'setenv.sh',
	'server.xml',
	'server.xml',
	'db.properties',
];
 */

function EumtalkHeader() {
	EumtalkGrid.setGridHeader([
			{	
				key: "standardtype",
				label: "File Name",
				width: "150",
				align: "left"
			},
			{	
				key: "setkey",
				label: "Node Name",
				width: "150",
				align: "left",
				addClass: function() {
					if (this.item.referencevalue == null || this.item.referencevalue == "") {
						return "add_non_cell";
					}
				}
			},
			{	
				key: "referenceValueType",
				label: "설정타입(가변/불변)",
				width: "150",
				align: "left"				
			},
			{	
				key: "referencevalue",
				label: "Reference Value	",
				width: "150",
				align: "left",
				addClass: function() {
					if (this.item.referencevalue != this.item.inputvalue) {
						return "add_diff_cell";
					}
				}
			},			
			{	
				key: "inputvalue",
				label: "Input Value",
				width: "150",
				align: "left",
				addClass: function() {
					if (this.item.referencevalue != this.item.inputvalue) {
						return "add_diff_cell";
					}
				}
			},
			{
				key: "description",
				label: "description",
				width: "250",
				align: "left"
			}
	]);
	EumtalkGrid.setGridConfig({
		targetID : "EumtalkDataList",
		height: "auto",
		paging: false,
		sort: false
	});
}


function eumtalk(){
	EumtalkHeader();
	document.getElementById("eumtalkChkAllBtn").addEventListener('click',SearchEumtalk);
}

function SearchEumtalk() {
	if(eumtalkValidFileType()){
		var view_isSaaS = $('input[name=isSaaS]:checked').val();
		var view_dbType =  $('label[for=radio_DBType_'+$('input[name="dbType"]:checked').val()+']').html();
		var view_wasType =  $('label[for=radio_wasType_'+$('input[name="wasType"]:checked').val()+']').html();
		var view_fileType = $("input[name='eumtalkType']:checked").val();
		
		$("#Eumtalk_selectIsSaaS").html(view_isSaaS);
		$("#Eumtalk_selectDB").html(view_dbType);
		$("#Eumtalk_selectWAS").html(view_wasType);
		
		$.ajax({
			url: "/covicore/propertiesEumtalk/list.do",
			type:"POST",
			data: {
				isSaaS: view_isSaaS,
				dbType: $('input[name="dbType"]:checked').val(),
				wasType: $('input[name="wasType"]:checked').val(),
				context: $('#inputEumtalkFile').val(),
				fileType : $("input[name='eumtalkType']:checked").val(),
				fileName : $("#propertyName_"+view_fileType).text()
			},
			success: function(data) {
				EumtalkGrid.bindGrid(data);
				setGridClass();
			}
		});
	}else{
		alert("선택한 파일과 같은 파일을 업로드 해주세요.");
	}
}
// 엑셀 저장
excelDownload = function(){
	var isSaaS = $('input[name=isSaaS]:checked').val();
	var dbType = $('input[name=dbType]:checked').val();
	var wasType = $('input[name=wasType]:checked').val();
	
	var form = $('<form></form>');
    form.attr('action', "/covicore/propertiesManage/propertiesExcelDown.do");
    form.attr('method', 'post');
    form.appendTo('body');
    form.append($('<input type="hidden" value="' + isSaaS + '" name=isSaaS>'));
    form.append($('<input type="hidden" value="' + dbType + '" name=dbType>'));
    form.append($('<input type="hidden" value="' + wasType + '" name=wasType>'));
    
    $("input[name='eumtalkType']:checked").each(function() {
    	form.append($('<input type="hidden" value="' + $(this).val() + '" name=propertiesArray[]>'));
    });
    
    $("input[name='serverList']:checked").each(function() {
    	form.append($('<input type="hidden" value="' + $(this).val() + '" name=serverArray[]>'));
    });
    
    form.submit();
};

// 파일 업로드

function eumtalkFileUpload(){
  document.getElementById('eumtalk_file_uploads').click();
}

function eumtalkFileDelete(){
	eumtalkPreview.innerHTML = "<p>파일을 선택해주세요</p>";
	document.getElementById("inputEumtalkFile").value = "";
}

eumtalkFile.addEventListener('change', showEumtalkTextFile);

function showEumtalkTextFile() {
    const selectedEumtalkFiles = eumtalkFile.files;

 	if(selectedEumtalkFiles.length > 0){
		eumtalkPreview.innerHTML = "";
	    for(const eumtalkFile of selectedEumtalkFiles) {
	        const eumtalkSummary = document.createElement('div');
			eumtalkSummary.id = 'filename';
	        eumtalkSummary.textContent = `${eumtalkFile.name}`;
	        const eumtalkReader = new FileReader();
			var fileContent = "";
			
	        eumtalkReader.onload = function () {
			 	var fileContentArray = this.result.split('\n');
				for(var line = 0; line < fileContentArray.length-1; line++){
					var fileline = fileContentArray[line];
			 	 	if(!fileline.startsWith("#")){
						fileContent += fileline+"\n";
					}
				}
				document.getElementById("inputEumtalkFile").value = fileContent;
	        };
	
	        eumtalkReader.readAsText(eumtalkFile, "UTF-8");
	        
	        eumtalkPreview.appendChild(eumtalkSummary);
	    }
	}
}

function eumtalkValidFileType() {
	var view_fileType = $("input[name='eumtalkType']:checked").val();
	var fileType1 = $("#propertyName_"+view_fileType).text();
	var fileType2 = $("#filename").text();
	
	if(fileType1.indexOf(fileType2) > -1) return true;
	else return false;
}
