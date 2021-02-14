package ast;
import lib.TypeException;

public class NotNode implements Node {

	private Node exp;

	public NotNode (Node e) {
		exp=e;
	}

	public String toPrint(String s) {
		return s+"Not\n" + exp.toPrint(s+"  ") ;
	}
	/*Da riguardare. Permette il not solo ai booleani */
	public Node typeCheck() throws TypeException {
		Node r= exp.typeCheck(); 
		if (!(r instanceof BoolTypeNode)) 
			throw new TypeException("Incompatible type in not");
		return new BoolTypeNode();
	}
	
	/* Per fare il not di un booleano pusha 1, poi il valore del booleano (0 false, 1 true) e poi sottrae. Cos�
	 * se era true (1) con la sottrazione fa a 0 (false). Viceversa se era false (0) con la sottrazione va a 1
	 * (true).
	 */
	public String codeGeneration() {
		return "push 1\n"+
				exp.codeGeneration() +
				"sub\n";
	}

}
