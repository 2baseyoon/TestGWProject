var infraGrid = new coviGrid();


const pEl = document.querySelector('.log');
const infrafile = document.querySelector('.infrafile');
const preview = document.querySelector('.preview');


const fileTypes = [
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

function InfraHeader() {
	infraGrid.setGridHeader([
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
	infraGrid.setGridConfig({
		targetID : "infraDataList",
		height: "auto",
		paging: false,
		sort: false
	});
}


function infra(){
	InfraHeader();
	SearchInfra();
}

function SearchInfra() {
	
	if(validFileType()){
		var view_isSaaS = $('input[name=isSaaS]:checked').val();
		var view_dbType =  $('label[for=radio_DBType_'+$('input[name="dbType"]:checked').val()+']').html();
		var view_wasType =  $('label[for=radio_wasType_'+$('input[name="wasType"]:checked').val()+']').html();
		var view_fileType = $("input[name='infraType']:checked").val();
		
		$("#Infra_selectIsSaaS").html(view_isSaaS);
		$("#Infra_selectDB").html(view_dbType);
		$("#Infra_selectWAS").html(view_wasType);
		
		$.ajax({
			url: "/covicore/propertiesInfra/list.do",
			type:"POST",
			data: {
				isSaaS: view_isSaaS,
				dbType: $('input[name="dbType"]:checked').val(),
				wasType: $('input[name="wasType"]:checked').val(),
				context: $('#inputInfraFile').val(),
				fileType : $("input[name='infraType']:checked").val(),
				fileName : $("#propertyName_"+view_fileType).text()
			},
			success: function(data) {
				infraGrid.bindGrid(data);
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
    
    $("input[name='infraType']:checked").each(function() {
    	form.append($('<input type="hidden" value="' + $(this).val() + '" name=propertiesArray[]>'));
    });
    
    $("input[name='serverList']:checked").each(function() {
    	form.append($('<input type="hidden" value="' + $(this).val() + '" name=serverArray[]>'));
    });
    
    form.submit();
};

// 파일 업로드

function fileUpload(){
  document.getElementById('file_uploads').click();
}

function fileDelete(){
	preview.innerHTML = "<p>파일을 선택해주세요</p>";
	document.getElementById("inputInfraFile").value = "";
}

infrafile.addEventListener('change', showTextFile);

function showTextFile() {
    const selectedFiles = infrafile.files;
	
 	if(selectedFiles.length > 0){
		preview.innerHTML = "";
	    for(const file of selectedFiles) {
	        const summary = document.createElement('div');
			summary.id = 'filename';
	        summary.textContent = `${file.name}`;        
	        const reader = new FileReader();
			var fileContent = "";
			
	        reader.onload = function () {
			 	var fileContentArray = this.result.split('\n');
				for(var line = 0; line < fileContentArray.length-1; line++){
					var fileline = fileContentArray[line];
			 	 	if(!fileline.startsWith("#")){
						fileContent += fileline+"\n";
					}
				}
				document.getElementById("inputInfraFile").value = fileContent;
	        };
	
	        reader.readAsText(file, "UTF-8");
	        
	        preview.appendChild(summary);
	    }
	}
}

function validFileType() {
	var view_fileType = $("input[name='infraType']:checked").val();
	var fileType1 = $("#propertyName_"+view_fileType).text();
	var fileType2 = $("#filename").text();
	
	if(fileType1.indexOf(fileType2) > -1) return true;
	else return false;
}
