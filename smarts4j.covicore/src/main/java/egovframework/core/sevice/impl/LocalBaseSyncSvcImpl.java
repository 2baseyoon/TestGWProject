/*
 * Copyright(c) 2019 Covision Corp. All rights reversed.
 *
 * @since 2019. 04. 22
 * @auth R&D Center Yoonseoung JI
 */
package egovframework.core.sevice.impl;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.baseframework.util.SessionHelper;
import egovframework.core.common.enums.SyncObjectType;
import egovframework.core.sevice.LocalBaseSyncSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.util.List;

/**
 * Define the class for caching the data for base config and code
 * @since 2019. 04. 23
 * @author Covision R&D YoonSeoung JI
 */
@Service("localBaseSyncSvc")
public class LocalBaseSyncSvcImpl extends EgovAbstractServiceImpl implements LocalBaseSyncSvc {

    @Resource(name="coviMapperOne")
    private CoviMapperOne coviMapperOne;

    /**
     * Define the method for getting the data of base config or code
     * @param sot The type of object for synchronizing object
     * @param params The parameter data for processing
     * @return The result of base config or code
     */
    @Override
    public CoviMap getSyncTargetList(SyncObjectType sot, CoviMap params) {
        CoviMap rtnData = new CoviMap();
        String domainId = SessionHelper.getSession("DN_ID");
        StringBuilder sb = new StringBuilder();

        params.put("sot", sot == SyncObjectType.BASE_CONFIG ? 1 : 0 );
        if( sot == SyncObjectType.BASE_CONFIG ) {

            params.put("domainId", "0");

            List<CoviMap> baseConfig_0 =
                    coviMapperOne.selectList( "sys.local.base.sync.selectSyncTarget", params );

            sb = this.concatObject( sb, baseConfig_0, false );

            rtnData.put("BaseConfig_0", sb.toString());

            params.put("domainId", domainId);
            List<CoviMap> baseConfig_1 =
                    coviMapperOne.selectList( "sys.local.base.sync.selectSyncTarget", params );

            sb = new StringBuilder();
            sb = this.concatObject( sb, baseConfig_1, false );
            rtnData.put("BaseConfig_" + domainId, sb.toString());

            /* 동기화 시간 조회
            String syncTime = coviMapperOne.selectOne("sys.local.base.sync.selectSyncTime", params);
            rtnData.put("BaseConfigSyncTime", syncTime);
*/

        } else if (sot == SyncObjectType.BASE_CODE) {

            List<CoviMap> baseCode =
                    coviMapperOne.selectList( "sys.local.base.sync.selectSyncTarget", params );
            String syncTime = coviMapperOne.selectOne("sys.local.base.sync.selectSyncTime", params);

            rtnData.put("BaseCode", this.concatObject( sb, baseCode, true ).toString());
            rtnData.put("BaseCodeSyncTime", syncTime);

        }

        return rtnData;
    }

    /**
     * Define the method for parsing the List Object to String Builder
     * @param builder The String Builder of the original data
     * @param list The List Object for parsing the data
     * @param firstValue The value to determine if this is the first item
     * @return Built String Builder
     */
    private StringBuilder concatObject(StringBuilder builder, List<CoviMap> list, boolean firstValue) {

        String dicSeparator = "†";
        String itemSeparator = "§";

        if(list != null) {
            for( CoviMap item: list ) {
                if( !firstValue )
                    builder.append( dicSeparator );
                else
                    firstValue = false;

                builder
                        .append(item.getString("SettingKey"))
                        .append(itemSeparator)
                        .append(item.getString("SettingValue"));
            }
        }

        return builder;

    }
    
    @Override
    public CoviList getBaseCode(String pKey) {
    
    	CoviMap params = new CoviMap();
		params.put("CodeGroup", pKey);
		params.put("DomainID", SessionHelper.getSession("DN_ID"));
	
		CoviList orgArrayList = new CoviList();
		
		orgArrayList = coviMapperOne.arrayList("basecode.selectBaseCode", params);
		//값이 없으면 공통에서 다시 조회하기.
		if (orgArrayList.size() == 0 && !SessionHelper.getSession("DN_ID").equals("0")){
			params.put("DomainID", "0");
			orgArrayList = coviMapperOne.arrayList("basecode.selectBaseCode", params);
		}
		return orgArrayList;
		
    }
}
