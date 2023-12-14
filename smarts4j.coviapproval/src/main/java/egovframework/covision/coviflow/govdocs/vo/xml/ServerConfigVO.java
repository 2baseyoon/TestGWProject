package egovframework.covision.coviflow.govdocs.vo.xml;

import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlType;

@XmlType(propOrder = {"ip","className","grLanguage","port"})
public class ServerConfigVO {

	private String ip;
	private String className;
	private String grLanguage;
	private String port;
	
	
	public String getIp() {
		return ip;
	}
	@XmlAttribute(name="ip")
	public void setIp(String ip) {
		this.ip = ip;
	}
	public String getClassName() {
		return className;
	}
	@XmlAttribute(name="className")
	public void setClassName(String className) {
		this.className = className;
	}
	public String getGrLanguage() {
		return grLanguage;
	}
	@XmlAttribute(name="grLanguage")
	public void setGrLanguage(String grLanguage) {
		this.grLanguage = grLanguage;
	}
	public String getPort() {
		return port;
	}
	@XmlAttribute(name="port")
	public void setPort(String port) {
		this.port = port;
	}
}
