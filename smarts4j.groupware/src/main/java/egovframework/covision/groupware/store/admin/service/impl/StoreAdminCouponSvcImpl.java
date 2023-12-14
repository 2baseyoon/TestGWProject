package egovframework.covision.groupware.store.admin.service.impl;

import java.text.SimpleDateFormat;
import java.util.Map;
import java.util.Set;

import javax.annotation.Resource;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.stereotype.Service;

import egovframework.baseframework.data.CoviList;
import egovframework.baseframework.data.CoviMap;
import egovframework.baseframework.data.CoviMapperOne;
import egovframework.coviframework.util.DateHelper;
import egovframework.coviframework.util.DicHelper;
import egovframework.baseframework.util.SessionHelper;
import egovframework.coviframework.util.ComUtils;
import egovframework.covision.groupware.store.admin.service.StoreAdminCouponSvc;
import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;

/**
 * Coupon 관리 Service
 * @author hgsong
 * @since 2022. 7. 26
 */
@Service("storeAdminCouponService")
public class StoreAdminCouponSvcImpl extends EgovAbstractServiceImpl implements StoreAdminCouponSvc {
	private static final Logger LOGGER = LogManager.getLogger(StoreAdminCouponSvcImpl.class);
	
	public static final String EVENTTYPE_PROMOTION 	= "PROMOTION";
	public static final String EVENTTYPE_CONTRACT 	= "CONTRACT";
	public static final String EVENTTYPE_CONSUME 	= "CONSUME";
	public static final String EVENTTYPE_EXPIRE 	= "EXPIRE";
	
	public static final String COUPONTYPE_APPFORM 		= "APPFORM";
	public static final String COUPONTYPE_CONTENTSAPP 	= "CONTENTSAPP";
	public static final String COUPONTYPE_PORTAL 		= "PORTAL";
	
	@Resource(name="coviMapperOne")
	private CoviMapperOne coviMapperOne;
	
	@Override
	public CoviMap getCouponListData(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		
		int cnt = (int) coviMapperOne.getNumber("store.coupon.admin.selectDomainCouponListCnt", params);
		page = ComUtils.setPagingData(params, cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("store.coupon.admin.selectDomainCouponList", params);
		setDateToString(list);
		resultList.put("list", list);
		resultList.put("page", page);
		
		return resultList;
	}

	/**
	 * 회사별 쿠폰관리 Event List
	 */
	@Override
	public CoviMap getCouponEventData(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		
		int cnt = (int) coviMapperOne.getNumber("store.coupon.admin.selectCouponEventListCnt", params);
		page = ComUtils.setPagingData(params, cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("store.coupon.admin.selectCouponEventList", params);
		setDateToString(list);
		resultList.put("list", list);
		resultList.put("page", page);
		
		return resultList;
	}

	/**
	 * 쿠폰 신규발행
	 */
	@Override
	public CoviMap addCouponData(CoviMap params) throws Exception {
		int issueCnt = params.optInt("IssueCnt");
		CoviList couponList = new CoviList();
		for(int i = 0; i < issueCnt; i++) {
			CoviMap item = new CoviMap();

			item.put("DomainID", params.getInt("DomainID"));
			item.put("CouponType", params.getString("CouponType"));
			item.put("ExpireDate", params.getString("ExpireDate"));
			item.put("IssueType", params.getString("IssueType"));
			item.put("IssueState", "NORMAL"); // 정상
			item.put("RegisterCode", SessionHelper.getSession("UR_Code"));
			couponList.add(item);
		}
		params.put("couponList", couponList);
		
		int qty = coviMapperOne.insert("store.coupon.admin.insertCoupon", params);
		
		// Event Parameters.
		params.put("EventType", params.getString("IssueType"));
		params.put("RegisterCode", SessionHelper.getSession("UR_Code"));
		params.put("EventUser", SessionHelper.getSession("UR_Name"));
		params.put("CouponQty", qty); // 증감수량
		coviMapperOne.insert("store.coupon.admin.insertCouponEvent", params);
		
		return null;
	}

	/**
	 * 쿠폰사용처리
	 */
	@Override
	public CoviMap updateCouponData(CoviMap params) throws Exception {
		// CouponID, ChgUserCode, RefID(Nullable)
		int cnt = coviMapperOne.insert("store.coupon.user.updateCouponUse", params);
		if(cnt < 1) {
			throw new Exception("This Coupon is invalid State");
		}
		
		// Event Parameters.
		params.put("CouponQty", -1); // 증감수량
		coviMapperOne.insert("store.coupon.admin.insertCouponEvent", params);
		
		return params;
	}

	/**
	 * 유효기간 지난 쿠폰 만료처리
	 */
	@Override
	public CoviMap expireCoupon(CoviMap params) throws Exception {
		String curDate = DateHelper.getCurrentDay("yyyyMMdd"); // yyyyMMdd
		params.put("CurDate", curDate);
		
		CoviList expireTargetList = coviMapperOne.list("store.coupon.admin.selectCouponExpire", params);
		
		for(int i = 0; expireTargetList != null && i < expireTargetList.size(); i++) {
			CoviMap info = expireTargetList.getJSONObject(i);
			
			// 회사별 만료처리 및 이벤트기록.
			params.put("DomainID", info.getString("DomainID"));
			params.put("CouponType", info.getString("CouponType"));
			
			int qty = coviMapperOne.update("store.coupon.admin.updateCouponExpire", params);
			
			if(qty > 0) {
				params.put("CouponQty", -1 * qty); // 증감수량
				params.put("EventType", "EXPIRE");
				params.put("Memo", DicHelper.getDic("msg_CouponExpire"));
				coviMapperOne.insert("store.coupon.admin.insertCouponEvent", params);
			}
		}
		
		return null;
	}

	@Override
	public CoviMap getDomainCouponInfo(CoviMap params) throws Exception {
		return coviMapperOne.select("store.coupon.admin.selectDomainCouponData", params);
	}

	@Override
	public CoviMap getCouponDetailListData(CoviMap params) throws Exception {
		CoviMap resultList = new CoviMap();
		CoviMap page = new CoviMap();
		
		int cnt = (int) coviMapperOne.getNumber("store.coupon.user.selectCouponDetailListCnt", params);
		page = ComUtils.setPagingData(params, cnt);
		params.addAll(page);
		
		CoviList list = coviMapperOne.list("store.coupon.user.selectCouponDetailList", params);
		setDateToString(list);
		resultList.put("list", list);
		resultList.put("page", page);
		
		return resultList;
	}
	
	private void setDateToString(CoviList list) {
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		for(int i = 0; list != null && i < list.size(); i++) {
			CoviMap item = (CoviMap)list.get(i);
			Set<Map.Entry<String, Object>> set = item.entrySet();
			for(Map.Entry<String, Object> entry : set) {
				if(entry.getValue() instanceof java.sql.Timestamp) {
					java.sql.Timestamp d = (java.sql.Timestamp)entry.getValue();
					entry.setValue(sdf.format(d));
				}
				if(entry.getValue() instanceof java.sql.Date) {
					java.sql.Date d = (java.sql.Date)entry.getValue();
					entry.setValue(sdf.format(d));					
				}
			}
		}
	}
}
