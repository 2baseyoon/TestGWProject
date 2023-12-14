package egovframework.coviframework.util.s3;

import com.amazonaws.services.s3.model.S3ObjectInputStream;

public class AwsS3Data {

	public String contentType;
	//public byte[] content;
	public long length;
	public String name;
	public String parentPath;
	public S3ObjectInputStream contentStream;
	
	public String getContentType() {
		return contentType;
	}

	public void setContentType(String contentType) {
		this.contentType = contentType;
	}

	public S3ObjectInputStream getContentStream() {
		return contentStream;
	}

	public void setContentStream(S3ObjectInputStream contentStream) {
		this.contentStream = contentStream;
	}

	public long getLength() {
		return length;
	}
	public void setLength(long  length) {
		this.length = length;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getName() {
		return name;
	}

	public void setParentPath(String parentPath) {
		this.parentPath = parentPath;
	}

	public String getParentPath() {
		return parentPath;
	}


}
