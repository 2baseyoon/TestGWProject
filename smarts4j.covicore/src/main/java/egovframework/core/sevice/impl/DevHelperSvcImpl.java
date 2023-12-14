package egovframework.core.sevice.impl;

import javax.annotation.Resource;




import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.core.sevice.DevHelperSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("devHelperService")
public class DevHelperSvcImpl extends EgovAbstractServiceImpl implements DevHelperSvc{
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Override
	public int updateModuleIsUse(CoviMap params) throws Exception {
		return coviMapperOne.update("devhelper.acl.updateModuleIsUse", params);
	}
	
	@Override
	public int updateModuleIsAdmin(CoviMap params) throws Exception {
		return coviMapperOne.update("devhelper.acl.updateModuleIsAdmin", params);
	}	
	
	@Override
	public int updateModuleIsAudit(CoviMap params) throws Exception {
		return coviMapperOne.update("devhelper.acl.updateModuleIsAudit", params);
	}
	
	@Override
	public int selectModuleDataCnt(CoviMap params) throws Exception {
		return (int)coviMapperOne.getNumber("devhelper.acl.selectModuleDataCnt", params);
	}
	
	@Override
	public CoviList selectModuleDataList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("devhelper.acl.selectModuleDataList", params);
		return CoviSelectSet.coviSelectJSON(list, "ModuleID,ModuleName,AuditMethod,AuditClass,URL,BizSection,IsUse,IsAdmin,IsAudit,Description,RegisterCode,RegistDate,ModifierCode,ModifyDate,PrgmID,PrgmName,AuditMenuNm");
	}
	
	@Override
	public int insertModuleData(CoviMap params) throws Exception {
		return coviMapperOne.insert("devhelper.acl.insertModuleData", params);
	}
	
	@Override
	public int insertPrgmData(CoviMap params) throws Exception {
		return coviMapperOne.insert("devhelper.acl.insertPrgmData", params);
	}
	
	@Override
	public int selectPrgmDataCnt(CoviMap params) throws Exception {
		return (int)coviMapperOne.getNumber("devhelper.acl.selectPrgmDataCnt", params);
	}
	
	@Override
	public CoviList selectPrgmDataList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("devhelper.acl.selectPrgmDataList", params);
		return CoviSelectSet.coviSelectJSON(list, "PrgmID,PrgmName,RegisterCode,RegistDate,ModifierCode,ModifyDate");
	}
	
	@Override
	public int selectPrgmMapDataCnt(CoviMap params) throws Exception {
		return (int)coviMapperOne.getNumber("devhelper.acl.selectPrgmMapDataCnt", params);
	}

	@Override
	public CoviList selectPrgmMapDataList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("devhelper.acl.selectPrgmMapDataList", params);
		return CoviSelectSet.coviSelectJSON(list, "PrgmID,ModuleID,RegisterCode,RegistDate,ModifierCode,ModifyDate");
	}	

	@Override
	public int selectPrgmMenuDataCnt(CoviMap params) throws Exception {
		return (int)coviMapperOne.getNumber("devhelper.acl.selectPrgmMenuDataCnt", params);
	}

	@Override
	public CoviList selectPrgmMenuDataList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("devhelper.acl.selectPrgmMenuDataList", params);
		return CoviSelectSet.coviSelectJSON(list, "MenuName,MenuID,PrgmID,ModifierCode,ModifyDate,RegisterCode,RegistDate");
	}
	
	@Override
	public int insertPrgmMapData(CoviMap params) throws Exception {
		return coviMapperOne.insert("devhelper.acl.insertPrgmMapData", params);
	}
	
	@Override
	public int selectMenuDataCnt(CoviMap params) throws Exception {
		return (int)coviMapperOne.getNumber("devhelper.acl.selectMenuDataCnt", params);
	}
	
	@Override
	public CoviList selectMenuDataList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("devhelper.acl.selectMenuDataList", params);
		return CoviSelectSet.coviSelectJSON(list, "MenuName,MenuID,BizSection,URL");
	}
	
	@Override
	public int insertPrgmMenuData(CoviMap params) throws Exception {
		return coviMapperOne.insert("devhelper.acl.insertPrgmMenuData", params);
	}
	
	@Override
	public int deleteModuleData(CoviMap params) throws Exception {
		return coviMapperOne.delete("devhelper.acl.deleteModuleData", params);
	}
	
	@Override
	public int deletePrgmData(CoviMap params) throws Exception {
		return coviMapperOne.delete("devhelper.acl.deletePrgmData", params);
	}
	
	@Override
	public int deletePrgmMapData(CoviMap params) throws Exception {
		return coviMapperOne.delete("devhelper.acl.deletePrgmMapData", params);
	}
	
	@Override
	public int deletePrgmMenuData(CoviMap params) throws Exception {
		return coviMapperOne.delete("devhelper.acl.deletePrgmMenuData", params);
	}
	
	@Override
	public int updateModuleData(CoviMap params) throws Exception {
		return coviMapperOne.update("devhelper.acl.updateModuleData", params);
	}
	
	@Override
	public int updatePrgmData(CoviMap params) throws Exception {
		return coviMapperOne.update("devhelper.acl.updatePrgmData", params);
	}
	
	@Override
	public int updatePrgmMenuData(CoviMap params) throws Exception {
		return coviMapperOne.update("devhelper.acl.updatePrgmMenuData", params);
	}
	
	@Override
	public CoviList selectModulePrgmMapList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("devhelper.acl.selectModulePrgmMapList", params);
		return CoviSelectSet.coviSelectJSON(list, "PrgmID,PrgmName");
	}
	
	@Override
	public CoviList selectBoardSampleList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("devhelper.board.selectBoardlistExample", params);
		return CoviSelectSet.coviSelectJSON(list, "MessageID,Subject,CreatorName,RegistDate");
	}
	
	@Override
	public int selectBoardlistCountExample(CoviMap params) throws Exception {
		return (int)coviMapperOne.getNumber("devhelper.board.selectBoardlistCountExample", params);
	}
}
