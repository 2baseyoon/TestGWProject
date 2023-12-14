package egovframework.core.properties.service.impl;

import java.sql.SQLException;
import java.sql.SQLIntegrityConstraintViolationException;
import java.util.List;

import javax.annotation.Resource;

import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.core.properties.dto.StandardSettingListRequest;
import egovframework.core.properties.dto.StandardSettingSaveRequest;
import egovframework.core.properties.service.StandardSettingSvc;

@Service("StandardSettingSvcImpl")
public class StandardSettingSvcImpl extends EgovAbstractServiceImpl implements StandardSettingSvc {
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public CoviList selectCodeList(CoviMap params) {
		return coviMapperOne.list("properties.context.selectCodeList", params);
	}
	
	@Override
	public CoviList selectStandardCodeList(CoviMap params) {
		return coviMapperOne.list("properties.context.selectStandardCodeList", params);
	}
	
	@Override
	public CoviList selectContextCodeList(CoviMap params) {
		return coviMapperOne.list("properties.context.selectContextCodeList", params);
	}
	
	@Override
	public CoviList selectInfraCodeList(CoviMap params) {
		return coviMapperOne.list("properties.context.selectInfraCodeList", params);
	}
	
	@Override
	public CoviMap list(StandardSettingListRequest standardSettingListRequest) {
		CoviList coviList = coviMapperOne.list("standard.setting.selectStandardSettingList", standardSettingListRequest.toCoviMap());
		
		return new CoviMap() {{
			this.put("list", coviList);
			this.put("page", new CoviMap() {{
				this.put("listCount", coviList.size());
			}});
		}};
	}

	@Override
	public CoviMap save(StandardSettingSaveRequest standardSettingSaveRequest)  {
		try {
			if (standardSettingSaveRequest.isId()) {
				coviMapperOne.update("standard.setting.updateStandardSetting", standardSettingSaveRequest.toCoviMap());
			}
			if (!standardSettingSaveRequest.isId()) {
				coviMapperOne.insert("standard.setting.insertStandardSetting", standardSettingSaveRequest.toCoviMap());
			}
		} catch (DataAccessException e) {
			if (e.getCause() instanceof java.sql.SQLIntegrityConstraintViolationException) {
				return new CoviMap() {{
					this.put("status", "fail");
					this.put("message", "키가 중복되었습니다. " + e.getCause().getMessage());
				}};
			}
		}
		
		return new CoviMap() {{
			this.put("status", "success");
		}};
	}

	@Override
	public void delete(List<Integer> ids) throws Exception {
		for (Integer id : ids) {
			coviMapperOne.delete("standard.setting.deleteStandardSetting", new CoviMap() {{ this.put("id", id); }});
		}
	}

	@Override
	public CoviMap findById(CoviMap params) throws Exception {
		return coviMapperOne.select("selectStandardSetting", params);
	}
}

