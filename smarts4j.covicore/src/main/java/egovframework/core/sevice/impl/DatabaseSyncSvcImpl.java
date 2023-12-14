package egovframework.core.sevice.impl;

import java.util.HashMap;

import javax.annotation.Resource;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.core.sevice.DatabaseSyncSvc;
import egovframework.coviframework.util.ComUtils;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;


/**
 * Target Manage External Database Sync.
 * @author hgsong
 */
@Service
public class DatabaseSyncSvcImpl extends EgovAbstractServiceImpl implements DatabaseSyncSvc {
	private static final Logger LOGGER = LogManager.getLogger(DatabaseSyncSvcImpl.class);
	
	final String propEncKey = "DevSaaS@)20";
	String poolNamePrefix = "sync";
	java.util.Map<String, String> poolNameMap = new HashMap<String, String>();
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;


	/**
	 * 동기화 대상 목록 조회
	 */
	@Override
	public CoviMap selectTargetList(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		
		int cnt = (int) coviMapperOne.getNumber("sys.dbsync.selectTargetCnt", params);
		CoviMap page = ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("sys.dbsync.selectTargetList", params);
		resultList.put("list", CoviSelectSet.coviSelectJSON(list));
		resultList.put("page", page);
		
		return resultList;
	}

	@Override
	public CoviMap selectTarget(CoviMap params) throws Exception {
		return coviMapperOne.select("sys.dbsync.selectTargetOne", params);
	}

	@Override
	public int insertTarget(CoviMap params) throws Exception {
		return coviMapperOne.insert("sys.dbsync.insertTarget", params);
	}

	@Override
	public int updateTarget(CoviMap params) throws Exception {
		return coviMapperOne.update("sys.dbsync.updateTarget", params);
	}
	
	@Override
	public int updateUse(CoviMap params) throws Exception {
		return coviMapperOne.update("sys.dbsync.updateTargetUse", params);
	}

	@Override
	public int deleteTarget(CoviMap params) throws Exception {
		return coviMapperOne.delete("sys.dbsync.deleteTarget", params);
	}

	@Override
	public int updateTargetResult(CoviMap params) throws Exception {
		return coviMapperOne.update("sys.dbsync.updateTargetResult", params);
	}
}
