package egovframework.coviframework.service;

import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.dto.StorageInfoDTO;


public interface StorageService {
	public CoviMap findAll(CoviMap params) throws Exception;
	public void save(StorageInfoDTO params) throws Exception;
	public void delete(int[] params) throws Exception;
	public CoviMap findById(int storageId);
	public void update(StorageInfoDTO storageInfoDTO) throws Exception;
	public void toggleActive(int storageId) throws Exception;
}
