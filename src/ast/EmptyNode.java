package ast;

/*Nodo per il campo null. */
public class EmptyNode implements Node {

	public EmptyNode () {

	}

	public String toPrint(String s) {
		return s+"Null\n";  
	}

	public Node typeCheck() {
		return new EmptyTypeNode(); 
	}
	/*Mette -1 sullo stack, come scritto nelle slide. Questo perch� -1 � diverso da qualsiasi indirizzo
	 * dello stack. */
	public String codeGeneration() {
		return "push -1\n";
	}
}
