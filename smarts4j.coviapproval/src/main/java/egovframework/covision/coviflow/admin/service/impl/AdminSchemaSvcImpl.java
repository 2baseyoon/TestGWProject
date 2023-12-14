package egovframework.covision.coviflow.admin.service.impl;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;


import egovframework.baseframework.util.json.JSONSerializer;
import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.coviflow.admin.service.AdminSchemaSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("adminSchemaService")
public class AdminSchemaSvcImpl extends EgovAbstractServiceImpl implements AdminSchemaSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public CoviMap select(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();

		int cnt = (int) coviMapperOne.getNumber("admin.schema.selectCount", params);
		page = ComUtils.setPagingData(params, cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("admin.schema.select", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list, "SCHEMA_ID,SCHEMA_NAME,SCHEMA_DESC,SCHEMA_CONTEXT,DOMAIN_CODE,DOMAIN_NAME"));
		resultList.put("page",page);
		
		return resultList;
	}

	@Override
	public Object insert(CoviMap params) throws Exception {
		coviMapperOne.insert("admin.schema.insert", params);
		
		CoviMap jsonObject = CoviMap.fromObject(JSONSerializer.toJSON(params.get("SCHEMA_CONTEXT")));
		
		jsonObject.getJSONObject("id").put("value", params.optString("SchemaID"));
		
		params.put("SCHEMA_CONTEXT", jsonObject.toString());
		params.put("SCHEMA_ID", params.optString("SchemaID"));		
		
		return coviMapperOne.update("admin.schema.update", params);
	}

	@Override
	public CoviMap selectOne(CoviMap params) throws Exception {
		CoviMap map = coviMapperOne.select("admin.schema.selectOne", params);
		
		CoviMap resultList = new CoviMap();
		resultList.put("map", CoviSelectSet.coviSelectJSON(map, "SCHEMA_ID,SCHEMA_NAME,SCHEMA_DESC,SCHEMA_CONTEXT,DOMAIN_ID"));
		return resultList;
	}

	@Override
	public int update(CoviMap params) throws Exception {
		return coviMapperOne.update("admin.schema.update", params);
	}

	@Override
	public int delete(CoviMap params) throws Exception {
		return coviMapperOne.delete("admin.schema.delete", params);
	}

	@Override
	public int selectForm(CoviMap params) throws Exception {
		return (int)coviMapperOne.getNumber("admin.schema.selectForm", params);
	}
}
