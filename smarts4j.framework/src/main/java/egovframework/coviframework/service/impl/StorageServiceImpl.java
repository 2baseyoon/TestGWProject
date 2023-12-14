package egovframework.coviframework.service.impl;

import java.util.Map;
import java.util.stream.Collectors;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.data.CoviSelectSet;
import egovframework.coviframework.dto.StorageInfoDTO;
import egovframework.coviframework.service.StorageService;
import egovframework.coviframework.util.ComUtils;
import egovframework.coviframework.util.FileUtil;
import egovframework.coviframework.vo.StorageInfo;


@Service("storageService")
public class StorageServiceImpl implements StorageService {

	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public CoviMap findAll(CoviMap params) throws Exception {
		CoviMap result = new CoviMap();
		
		int pageNo		= Integer.parseInt(params.get("pageNo").toString());
		int pageSize	= Integer.parseInt(params.get("pageSize").toString());
		int pageOffset	= (pageNo - 1) * pageSize;
		
		params.put("pageNo",		pageNo);
		params.put("pageSize",		pageSize);
		params.put("pageOffset",	pageOffset);
		
		int cnt = (int) coviMapperOne.getNumber("framework.FileUtil.selectStorageInfoListCnt" , params);
		
		CoviMap page = ComUtils.setPagingData(params,cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("framework.FileUtil.selectStorageInfoList", params);
		result.put("list", CoviSelectSet.coviSelectJSON(list));
		result.put("page", page);
		return result;
	}
	
	@Override
	public CoviMap findById(int storageId) {	
		CoviMap param = new CoviMap();
		param.put("storageId",storageId);
		return coviMapperOne.select("framework.FileUtil.selectStorageInfoById", param);
	}

	@Override
	public void save(StorageInfoDTO params) throws Exception {		
		StorageInfo storage = params.toEntity();
		
		int existID = coviMapperOne.selectOne("framework.FileUtil.selectStorageId", storage);
		if(existID > 0) {
			throw new IllegalStateException("already exists");
		}
		
		int result = coviMapperOne.insert("framework.FileUtil.insertStorageInfo", storage);
		if(result <= 0) {
			throw new IllegalStateException("not saved");
		}
		
		FileUtil.setStorageInfo();
	}

	@Override
	public void update(StorageInfoDTO storageInfoDTO) throws Exception {	
		StorageInfo storage = storageInfoDTO.toEntity();
		int existID = coviMapperOne.selectOne("framework.FileUtil.selectStorageId", storage);
		if(existID > 0 && existID != storage.getStorageID()) {
			throw new IllegalStateException("already exists");
		}
		
		int result = coviMapperOne.update("framework.FileUtil.updateStorageInfo", storage);
		if(result <= 0) {
			throw new IllegalStateException("not saved");
		}		
		FileUtil.setStorageInfo();
	}

	@Override
	public void toggleActive(int storageId) throws Exception {
		coviMapperOne.update("framework.FileUtil.toggleStorageActiveById", storageId);
		FileUtil.setStorageInfo();
	}
	
	@Override
	public void delete(int[] storageIds) throws Exception {
		coviMapperOne.delete("framework.FileUtil.deleteStorageInfoByIds", storageIds);
		FileUtil.setStorageInfo();
	}
}
