package egovframework.coviaccount.interfaceUtil.interfaceDao;

import java.util.ArrayList;

import egovframework.coviaccount.interfaceUtil.interfaceVO.CardBillVO;

public class CardBillDao{

	private ArrayList<CardBillVO> cardBillList = new ArrayList<CardBillVO>();

	public ArrayList<CardBillVO> getCardBillList() {
		return cardBillList;
	}

	public void setCardBillList(ArrayList<CardBillVO> cardBillList) {
		this.cardBillList = cardBillList;
	}
}
