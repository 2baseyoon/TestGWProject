package egovframework.core.sevice;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.core.common.enums.SyncObjectType;


public interface LocalBaseSyncSvc {

    /**
     * 동기화 시간 조회
     * @return String
     * @throws Exception
     * @author dyjo
     * @since 2019.04.16
     */
    //String getSyncTime(SyncObjectType sot) throws Exception;

    /**
     * 동기화 정보 저장
     * @return int
     * @throws Exception
     * @author dyjo
     * @since 2019.04.16
     */
    //int saveSyncInfo(SyncObjectType sot) throws Exception;

    /**
     * 동기화 대상 목록 조회
     * @param params
     * @return JSONObject
     * @throws Exception
     * @author dyjo
     * @since 2019.04.16
     */
    CoviMap getSyncTargetList(SyncObjectType sot, CoviMap params) throws Exception;
    
    CoviList getBaseCode(String pKey) throws Exception;

}
