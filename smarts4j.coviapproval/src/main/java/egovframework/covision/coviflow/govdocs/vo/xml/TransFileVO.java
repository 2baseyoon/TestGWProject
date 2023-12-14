package egovframework.covision.coviflow.govdocs.vo.xml;

import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlType;

@XmlType(propOrder = {"path","name","size"})
public class TransFileVO {

	private String path;
	private String name;
	private String size;
	
	
	
	public String getPath() {
		return path;
	}
	@XmlAttribute(name="path")
	public void setPath(String path) {
		this.path = path;
	}
	public String getName() {
		return name;
	}
	@XmlAttribute(name="name")
	public void setName(String name) {
		this.name = name;
	}
	public String getSize() {
		return size;
	}
	@XmlAttribute(name="size")
	public void setSize(String size) {
		this.size = size;
	}
		
	
	
}
