package egovframework.coviaccount.interfaceUtil.interfaceDao;

import java.util.ArrayList;

import egovframework.coviaccount.interfaceUtil.interfaceVO.CardReceiptVO;

public class CardReceiptDao {
	
	private ArrayList<CardReceiptVO> cardReceiptList = new ArrayList<CardReceiptVO>();
	
	public ArrayList<CardReceiptVO> getCardReceiptList(){
		return cardReceiptList;
	}
	
	public void setCardReceiptList(ArrayList<CardReceiptVO> cardReceiptList){
		this.cardReceiptList = cardReceiptList;
	}
}
