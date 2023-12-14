package egovframework.covision.coviflow.govdocs.vo.xml;

import java.util.List;

import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlElementWrapper;
import javax.xml.bind.annotation.XmlRootElement;
import javax.xml.bind.annotation.XmlType;

 
/*
 * 참조
 * https://howtodoinjava.com/jaxb/
 * */

/* 	
 * pack.dtd version : 2.0 - 2019.02
 * Typical usage:
      <?XML version="1.0" encoding="euc-kr" ?>
      <!DOCTYPE pack SYSTEM "pack.dtd">
      <pack> ... </pack>
 */


/*
 *  <!ELEMENT pack (header, contents)>
 *	<!ATTLIST pack filename CDATA #REQUIRED >
 *
 * <exchange year=“2003” key="???" orgCode="1310093" onePlatformYN="N" onLineYN="Y" rcCode="1310091" workCode="PROD_REPORT" workDiv="product">
 * 
 */
@XmlRootElement(name="exchange")
@XmlType(propOrder = {"year","key","orgCode", "onePlatformYN", "onLineYN", "rcCode", "workCode", "workDiv", "send", "receive", "fileList"})
public class ExchangeXmlVO {	
	
	private String year;
	private String key;
	private String orgCode;
	private String onePlatformYN;
	private String onLineYN;
	private String rcCode;
	private String workCode;
	private String workDiv;
	
	
	private ServerConfigVO send;
	private ServerConfigVO receive;
	private List<TransFileVO> file;
	
	
	
	public String getYear() {
		return year;
	}
	@XmlAttribute(name="year")
	public void setYear(String year) {
		this.year = year;
	}
	public String getKey() {
		return key;
	}
	@XmlAttribute(name="key")
	public void setKey(String key) {
		this.key = key;
	}
	public String getOrgCode() {
		return orgCode;
	}
	@XmlAttribute(name="orgCode")
	public void setOrgCode(String orgCode) {
		this.orgCode = orgCode;
	}
	public String getOnePlatformYN() {
		return onePlatformYN;
	}
	@XmlAttribute(name="onePlatformYN")
	public void setOnePlatformYN(String onePlatformYN) {
		this.onePlatformYN = onePlatformYN;
	}
	public String getOnLineYN() {
		return onLineYN;
	}
	@XmlAttribute(name="onLineYN")
	public void setOnLineYN(String onLineYN) {
		this.onLineYN = onLineYN;
	}
	public String getRcCode() {
		return rcCode;
	}
	@XmlAttribute(name="rcCode")
	public void setRcCode(String rcCode) {
		this.rcCode = rcCode;
	}
	public String getWorkCode() {
		return workCode;
	}
	@XmlAttribute(name="workCode")
	public void setWorkCode(String workCode) {
		this.workCode = workCode;
	}
	public String getWorkDiv() {
		return workDiv;
	}
	@XmlAttribute(name="workDiv")
	public void setWorkDiv(String workDiv) {
		this.workDiv = workDiv;
	}
	
	
	
	public ServerConfigVO getSend() {
		return send;
	}
	@XmlElement(name="send")
	public void setSend(ServerConfigVO send) {
		this.send = send;
	}
	public ServerConfigVO getReceive() {
		return receive;
	}
	@XmlElement(name="receive")
	public void setReceive(ServerConfigVO receive) {
		this.receive = receive;
	}
	public List<TransFileVO> getFileList() {
		return file;
	}
	@XmlElementWrapper(name="fileList")
	@XmlElement(name="file")
	public void setFileList(List<TransFileVO> file) {
		this.file = file;
	}
	
}
