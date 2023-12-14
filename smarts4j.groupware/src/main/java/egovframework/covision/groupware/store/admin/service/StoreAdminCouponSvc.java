package egovframework.covision.groupware.store.admin.service;

import egovframework.baseframework.data.CoviMap;

public interface StoreAdminCouponSvc {

	public CoviMap getCouponListData(CoviMap params) throws Exception;
	public CoviMap getCouponEventData(CoviMap params) throws Exception; // 쿠폰 사용/적립 내역
	public CoviMap addCouponData(CoviMap params) throws Exception; // 쿠폰적립
	/**
	 * 구매자가 사용할 쿠폰목록
	 * @param params
	 * @return
	 * @throws Exception
	 */
	public CoviMap getCouponDetailListData(CoviMap params) throws Exception;
	
	// API
	public CoviMap updateCouponData(CoviMap params) throws Exception; // 쿠폰사용
	public CoviMap expireCoupon(CoviMap params) throws Exception; // 쿠폰만료처리(스케쥴러)
	public CoviMap getDomainCouponInfo(CoviMap params) throws Exception; // 쿠폰현황 (총갯수, 사용갯수, 잔여갯수)
}
