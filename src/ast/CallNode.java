package ast;

import java.util.ArrayList;
import java.util.List;

import lib.*;


public class CallNode implements Node {

	private String id;
	private int nestingLevel;
	private STentry entry;
	private List<Node> parlist = new ArrayList<Node>();

	public CallNode(String i, STentry st, List<Node> p, int nl) {
		id = i;
		entry = st;
		parlist = p;
		nestingLevel = nl;
	}
	
	public Node getType() {
		return entry.getType( );
	}

	public String toPrint(String s) {
		String parlstr = "";
		for (Node par : parlist)
			parlstr += par.toPrint(s + "    ");
		return s + "Call: " + id + "\n" + entry.toPrint(s + "  ") + s + "  pars:\n" + parlstr;
	}

	public Node typeCheck() throws TypeException {
		if (!(entry.getType() instanceof ArrowTypeNode))
			throw new TypeException("Invocation of a non-function " + id); // gi� implementato?
		ArrowTypeNode t = (ArrowTypeNode) entry.getType();
		List<Node> p = t.getParList();
		if (!(p.size() == parlist.size()))
			throw new TypeException("[CallNode] Wrong number of parameters in the invocation of " + id);
		for (int i = 0; i < parlist.size(); i++)
			if (!(FOOLlib.isSubtype(parlist.get(i).typeCheck(), p.get(i)))) {
				throw new TypeException("Wrong type for " + (i + 1) + "-th parameter in the invocation of " + id);
			}
		return t.getRet();
	}


	public String codeGeneration() {
		String parCode = "";
		for (int i = parlist.size() - 1; i >= 0; i--)
			parCode += parlist.get(i).codeGeneration();
		String getAR = "";
		for (int i = 0; i < nestingLevel - entry.getNestingLevel(); i++)
			getAR += "lw\n";
		
		if(entry.isMethod()) {
			return  "lfp\n"+ // push Control Link (pointer to frame of function id caller)
			         parCode+ // generate code for parameter expressions in reversed order
			         "lfp\n"+
		             getAR+ // push Access Link (pointer to frame of function id declaration, reached as for variable id)
			         "stm\n"+"ltm\n"+"ltm\n"+ // duplicate top of the stack
			         "lw\n" + //vado nella DT
			         "push "+ entry.getOffset() + "\n"+ //pusho indirizzo della funzione recuperato a offset ID
					 "add\n"+
		             "lw\n"+ // push function address (value at: pointer to frame of function id declaration + its offset)
			         "js\n";// jump to popped address (putting in $ra address of subsequent instruction)
		} else {
			return "lfp\n" +// push Control Link (pointer to frame of function id caller)
					parCode +// generate code for parameter expressions in reversed order
					"lfp\n" +
					getAR + // Find the correct AR address.
					"push " + entry.getOffset() + "\n" + // push indirizzo ad AR dichiarazione funzione, recuperato a offset ID
					"add\n" + 
					"stm\n" + // duplicate top of the stack.
					"ltm\n" +
					"lw\n" + 
					"ltm\n" + // ripusho l'indirizzo ottenuto precedentemente, per poi calcolarmi offset ID - 1
					"push 1\n" + // push 1, 
					"sub\n" + // sottraggo a offset ID - 1, per recuperare l'indirizzo funzione.
					"lw\n" + // push function address.
					"js\n";
		}
		/*if(entry.isMethod()) {
			return "lfp\n" +// push Control Link (pointer to frame of function id caller)
					parCode +// generate code for parameter expressions in reversed order
					"lfp\n" +
					getAR + // Find the correct AR address.
					"push " + entry.getOffset() + "\n" + // push indirizzo ad AR dichiarazione funzione, recuperato a offset ID
					"add\n" + 
					"stm\n" + // duplicate top of the stack.
					"ltm\n" +
					"lw\n" + 
					"ltm\n" + // ripusho l'indirizzo ottenuto precedentemente, per poi calcolarmi offset ID - 1
					"lw\n" + //Per raggiungere la DT
					"push " + entry.getOffset() + "\n" +
					"add\n" +
					"js\n";
		} else {
			return "lfp\n" +// push Control Link (pointer to frame of function id caller)
					parCode +// generate code for parameter expressions in reversed order
					"lfp\n" +
					getAR + // Find the correct AR address.
					"push " + entry.getOffset() + "\n" + // push indirizzo ad AR dichiarazione funzione, recuperato a offset ID
					"add\n" + 
					"stm\n"+ // duplicate top of the stack.
					"ltm\n"+
					"lw\n" + 
					"ltm\n" + // ripusho l'indirizzo ottenuto precedentemente, per poi calcolarmi offset ID - 1
					"push 1\n" + // push 1, 
					"sub\n" + // sottraggo a offset ID - 1, per recuperare l'indirizzo funzione.
					"lw\n" + // push function address.
					"js\n";
		}*/
	}
}