package ast;

import lib.TypeException;

public class RefTypeNode implements Node {

	private String id;
	
	
	public RefTypeNode( String id ) {
		this.id = id;
	}
	
	public String getID( ) {
		return this.id;
	}
	
	@Override
	public String toPrint(String indent) {
		return indent + "Reference of class: " + this.id + "\n" ;
	}

	@Override
	public Node typeCheck() throws TypeException {
		return null;
	}

	@Override
	public String codeGeneration() {
		// TODO Auto-generated method stub
		return null;
	}

}
