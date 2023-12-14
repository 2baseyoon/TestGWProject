package egovframework.covision.coviflow.admin.service.impl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.covision.coviflow.admin.service.AdminDocumentInfoSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("adminDocumentInfoSvc")
public class AdminDocumentInfoSvcImpl extends EgovAbstractServiceImpl implements AdminDocumentInfoSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Override
	public void updateDocData(CoviMap params) throws Exception {
		String dataType = params.getString("dataType");
		
		switch (dataType) {
		case "Subject":
			coviMapperOne.update("admin.adminDocumentInfo.updateJwf_forminstanceData", params);
			coviMapperOne.update("admin.adminDocumentInfo.updateJwf_processData", params);
			coviMapperOne.update("admin.adminDocumentInfo.updateJwf_processdescriptionData", params);
			//coviMapperOne.update("admin.adminDocumentInfo.updateJwf_processArchiveData", params);
			coviMapperOne.update("admin.adminDocumentInfo.updateJwf_processdescriptionArchiveData", params);
			coviMapperOne.update("admin.adminDocumentInfo.updateJwf_circulationboxData", params);
			coviMapperOne.update("admin.adminDocumentInfo.updateJwf_circulationboxdescriptionData", params);
			break;
		case "IsSecureDoc":
			coviMapperOne.update("admin.adminDocumentInfo.updateJwf_processdescriptionData", params);
			coviMapperOne.update("admin.adminDocumentInfo.updateJwf_processdescriptionArchiveData", params);
			coviMapperOne.update("admin.adminDocumentInfo.updateJwf_circulationboxdescriptionData", params);
			break;
		case "DocNo":
			coviMapperOne.update("admin.adminDocumentInfo.updateJwf_forminstanceData", params);
			coviMapperOne.update("admin.adminDocumentInfo.updateJwf_processdescriptionArchiveData", params);
			break;
		case "BodyContext":
			coviMapperOne.update("admin.adminDocumentInfo.updateJwf_forminstanceData", params);
			break;
		case "DocLinks":
			coviMapperOne.update("admin.adminDocumentInfo.updateJwf_forminstanceData", params);
			break;
		case "AttachFileInfo":
			coviMapperOne.update("admin.adminDocumentInfo.updateJwf_forminstanceData", params);
			break;
		default:
			break;
		}
	}

	@Override
	public int deleteClearDel(CoviMap params) throws Exception {
		int cnt = 0;

		cnt  = coviMapperOne.delete("admin.adminDocumentInfo.deleteJwf_circulationbox", params);
		cnt  = coviMapperOne.delete("admin.adminDocumentInfo.deleteJwf_circulationread", params);
		cnt  = coviMapperOne.delete("admin.adminDocumentInfo.deleteJwf_circulationboxdescription", params);
		cnt  = coviMapperOne.delete("admin.adminDocumentInfo.deleteJwf_comment", params);
		cnt  = coviMapperOne.delete("admin.adminDocumentInfo.deleteJwf_docreadhistory", params);
		cnt  = coviMapperOne.delete("admin.adminDocumentInfo.deleteJwf_formhistory", params);
		//cnt  = coviMapperOne.delete("admin.adminDocumentInfo.deleteJwf_workitemdescription", params);
		cnt  = coviMapperOne.delete("admin.adminDocumentInfo.deleteJwf_workitem", params);
		cnt  = coviMapperOne.delete("admin.adminDocumentInfo.deleteJwf_performer", params);
		cnt  = coviMapperOne.delete("admin.adminDocumentInfo.deleteJwf_userfolerlistdescription", params);
		cnt  = coviMapperOne.delete("admin.adminDocumentInfo.deleteJwf_userfolderlist", params);
		cnt  = coviMapperOne.delete("admin.adminDocumentInfo.deleteJwf_forminstance", params);
		cnt  = coviMapperOne.delete("admin.adminDocumentInfo.deleteJwf_process", params);
		cnt  = coviMapperOne.delete("admin.adminDocumentInfo.deleteJwf_processdescription", params);
		cnt  = coviMapperOne.delete("admin.adminDocumentInfo.deleteJwf_workitemarchive", params);
		//cnt  = coviMapperOne.delete("admin.adminDocumentInfo.deleteJwf_workitemdescriptionarchive", params);
		cnt  = coviMapperOne.delete("admin.adminDocumentInfo.deleteJwf_processarchive", params);
		cnt  = coviMapperOne.delete("admin.adminDocumentInfo.deleteJwf_processdescriptionarchive", params);
		cnt  = coviMapperOne.delete("admin.adminDocumentInfo.deleteJwf_timelinemessaging", params);

		return cnt;
	}

	@Override
	public int deleteMarkingDel(CoviMap params) throws Exception {
		int cnt = 0;
		
		//params.put("DeletedDate", "NOW(3)");
		params.put("isDeleted", "Y");
		
		cnt  = coviMapperOne.update("admin.adminDocumentInfo.updateClearDelJwf_forminstance", params);
		cnt  = coviMapperOne.update("admin.adminDocumentInfo.updateClearDelJwf_process", params);
		cnt  = coviMapperOne.update("admin.adminDocumentInfo.updateClearDelJwf_workitem", params);
		//cnt  = coviMapperOne.update("admin.adminDocumentInfo.updateClearDelJwf_processarchive", params);
		//cnt  = coviMapperOne.update("admin.adminDocumentInfo.updateClearDelJwf_workitemarchive", params);
		cnt  = coviMapperOne.update("admin.adminDocumentInfo.updateClearDelJwf_timelinemessaging", params);
		return cnt;
	}

	@Override
	public int markingRollBack(CoviMap params) throws Exception {
		int cnt = 0;
		
		//params.put("DeletedDate", "null");
		params.put("isDeleted", "N");
		
		cnt  = coviMapperOne.update("admin.adminDocumentInfo.updateClearDelJwf_forminstance", params);
		cnt  = coviMapperOne.update("admin.adminDocumentInfo.updateClearDelJwf_process", params);
		cnt  = coviMapperOne.update("admin.adminDocumentInfo.updateClearDelJwf_workitem", params);
		//cnt  = coviMapperOne.update("admin.adminDocumentInfo.updateClearDelJwf_processarchive", params);
		//cnt  = coviMapperOne.update("admin.adminDocumentInfo.updateClearDelJwf_workitemarchive", params);
		cnt  = coviMapperOne.update("admin.adminDocumentInfo.updateClearDelJwf_timelinemessaging", params);
		return cnt;
	}

}
