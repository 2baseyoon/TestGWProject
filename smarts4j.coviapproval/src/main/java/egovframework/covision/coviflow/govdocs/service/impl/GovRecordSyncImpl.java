package egovframework.covision.coviflow.govdocs.service.impl;

import javax.annotation.Resource;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.covision.coviflow.govdocs.service.GovRecordSyncSvc;
import egovframework.covision.coviflow.user.service.SeriesListSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

@Service("govRecordSyncService")
public class GovRecordSyncImpl extends EgovAbstractServiceImpl implements GovRecordSyncSvc{

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;

	@Autowired
	private SeriesListSvc seriesListSvc;
	
	@Override
	public CoviList selectRecordGFileData(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("user.record.trans.selectRecordGFileData", params);
		return list;
	}
	
	@Override
	public CoviList selectRecordDocList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("user.record.trans.selectRecordDocList",params);
		return list;
	}
	
	@Override
	public CoviList selectRecordDocPageList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("user.record.trans.selectRecordDocPageList",params);
		return list;
	}
	
	@Override
	public CoviList selectRecordHistoryList(CoviMap params) throws Exception {
		CoviList list = coviMapperOne.list("user.record.trans.selectRecordHistoryList",params);
		return list;
	}
	
	@Override
	public CoviMap selectStorageInfo(CoviMap params) throws Exception {
		CoviMap map = coviMapperOne.select("framework.editor.selectStorageInfo", params);
		return map;
	}
	
	@Override
	public int updateSyncSeries(CoviList list) throws Exception{
		int i = 0;
		for(i = 0; i < list.size(); i++){
			CoviMap params = list.getMap(i);
			coviMapperOne.update("user.series.KICupdateSyncSeries", params);
			coviMapperOne.update("user.series.KICupdateSyncSeriesMapping", params);
		}
		return i;
	}
	
	@Override
	public int updateRecordGfileStatus(CoviMap params) throws Exception{
		return coviMapperOne.update("user.record.trans.updateRecordGfileStatus", params);
	}
	
	@Override
	public CoviMap selectJwfForminstance(CoviMap params) throws Exception {
		CoviMap map = coviMapperOne.select("user.record.trans.selectJwfForminstance", params);
		return map;
	}
	
	@Override
	public CoviList selectSendMailList() throws Exception{
		CoviList list = coviMapperOne.list("user.record.trans.selectSendMailList",null);
		return list;
	}
	
	@Override
	public CoviMap selectGovRecordDocInfo(CoviMap params) throws Exception {
		CoviMap map =  coviMapperOne.select("form.recorddocinfo.selectRecordDocInfo",params);
		return map;
	}
	
}
