package egovframework.coviframework.service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.coviframework.vo.MessageVO;

public interface MessageService {
	
	public int insertMessagingData(CoviMap params) throws Exception;
	public void updateMessagingData(CoviMap params) throws Exception;
	public void deleteMessagingData(CoviMap params) throws Exception;
	public void updateMessagingState(int messagingState, String serviceType, String objectType, int objectID, String searchType) throws Exception;
	public void updateArrMessagingState(int messagingState, String serviceType,	String objectType, CoviList objectID, String searchType)	throws Exception;
	public CoviMap getDicInfo(CoviMap params) throws Exception;
}
