package ast;

import java.util.ArrayList;
import java.util.List;

import lib.FOOLlib;
import lib.TypeException;

public class ClassCallNode implements Node {
	
	private int nestingLevel;
	private STentry entry;	//Tipo dell'obj su cui richiamo il metodo
	private STentry methodEntry; //Mio metodo
	private List<Node> parlist; //lista di parametri passati
	private String idMethod; //TODO valutare se va bene
	
	public ClassCallNode( STentry entry, String idMethod, STentry methodEntry, int nestingLevel ) {
		this.entry = entry;
		this.methodEntry = methodEntry;
		this.nestingLevel = nestingLevel;
		parlist = new ArrayList<Node>( );
		this.idMethod = idMethod;
	}

	public void addPar( Node parameter ) {
		parlist.add( parameter );
	}
	
	public Node getType() {
		return methodEntry.getType( );
	}
	
	@Override
	public String toPrint(String s) {
		String parstr = "";
		for (Node p : parlist)
			parstr += p.toPrint(s + "  ");
		
		return s + "Class call of method: '" + idMethod + "'\n" + s + methodEntry.getType( ).toPrint(s + "  ");
	}

	@Override
	public Node typeCheck() throws TypeException {
		if (!(methodEntry.getType() instanceof ArrowTypeNode)) {
			System.out.println(methodEntry.getType().getClass());
			throw new TypeException("Invocation of a non-method " + this.idMethod);
		}

		ArrowTypeNode arrowNode = (ArrowTypeNode) methodEntry.getType();
		List<Node> p = arrowNode.getParList();
		int count = 0;
		if (!(p.size() == parlist.size()))
			throw new TypeException("[ClassCallNode] Wrong number of parameters in the invocation of method " + this.idMethod);
		
		for(Node par : parlist) {
			
			if ( par instanceof IdNode )
				par = ( ( IdNode ) par).getEntry( ).getType( );
			else if ( par instanceof DecNode )
				par = ( ( DecNode )par ).getSymType( );
			else if ( par instanceof CallNode )
				par = ( ( CallNode ) par ).getType( );
			else if ( par instanceof ClassCallNode )
				par = ( ( ClassCallNode )par ).getType( );
			else par = par.typeCheck( );

			if ( par instanceof ArrowTypeNode )
				par = ( ( ArrowTypeNode )par ).getRet( );
			
			if (!(FOOLlib.isSubtype( par, ( (ParNode) p.get(count) ).getSymType())))
				throw new TypeException("[ClassCallNode] Wrong type of parameter for method call" );
			count++;
		}
		
		return arrowNode.getRet();
	}

	@Override
	public String codeGeneration() {

		String parCode = "";
		for (int i = parlist.size() - 1; i >= 0; i--)
			parCode += parlist.get(i).codeGeneration();
		String getAR = "";
		for (int i = 0; i < nestingLevel - entry.getNestingLevel(); i++)
			getAR += "lw\n";

		return "lfp\n" +// push Control Link (pointer to frame of function id caller)
				parCode +// generate code for parameter expressions in reversed order
				"lfp\n" +
				getAR + // Find the correct AR address.
				"push " + entry.getOffset() + "\n" + // push indirizzo ad AR dichiarazione funzione, recuperato a offset ID 
				"add\n"+ //Cos� ho l'Obj Pointer dell'obj nell'AR
				"lw\n" +//Carico sullo stack
				"stm\n" + "ltm\n" + "ltm\n" + // duplico il val sullo stack
				"lw\n" + // stack <- indirizzo dt --- paul (?)
				"push " + methodEntry.getOffset() + "\n"+
				"add\n" +
				"lw\n" + //Carico sullo stack
				"js\n"; //Salto all'indirizzo
	}

}
