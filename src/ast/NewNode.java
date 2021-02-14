package ast;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

import lib.FOOLlib;
import lib.TypeException;

public class NewNode implements Node {

	private STentry entry;
	private List<Node> fields;
	private String id;
	
	public NewNode( STentry entry, String name ) {
		this.entry = entry;
		fields = new ArrayList<Node>( );
		this.id = name;
	}
	
	public List<Node> getFields(){
		return this.fields;
	}
	
	public void setField( Node field ) {
		fields.add( field );
	}

	@Override
	public String toPrint( String indent ) {
		return indent + "Class: " + this.id + "\n" +
				fields.stream( ).map( s -> s.toPrint( indent + "\t" ) ).collect( Collectors.joining( ) );
	}

	@Override
	public Node typeCheck() throws TypeException {
		if (!(entry.getType() instanceof ClassTypeNode))
			throw new TypeException("Invocation of a non-class " + this.id);
		
		RefTypeNode refTypeNode = new RefTypeNode(this.id);
		
		ClassTypeNode ctn = (ClassTypeNode) entry.getType();
		List<Node> requiredFields = ctn.getAllFields();
		
		if (!(requiredFields.size() == fields.size()))
			throw new TypeException("[NewNode] Wrong number of parameters in the invocation of " + this.id + " p.size" + ctn.getAllFields().size() + " fieldSize:" + fields.size());
		int count = 0;
		
		Node f = null;
		FieldNode ef = null;
		
		for(Node field : fields) {
			f = field;
			ef = (FieldNode)requiredFields.get(count);
			
			if ( f instanceof IdNode )
				f = ( ( IdNode ) f).getEntry( ).getType( );
			else if ( f instanceof DecNode )
				f = ( ( DecNode ) f ).getSymType( );
			else if ( f instanceof CallNode )
				f = ( ( CallNode ) f ).getType( );
			else if ( f instanceof ClassCallNode )
				f = ( ( ClassCallNode ) f ).getType( );
			else f = f.typeCheck( );

			if ( f instanceof ArrowTypeNode )
				f = ( ( ArrowTypeNode )f ).getRet( );
			
			if ( !( FOOLlib.isSubtype( f, ef.getSymType()) ) ) {
				System.out.println( f.getClass() );
				System.out.println( ef.toPrint("") );
				throw new TypeException("Wrong type of fields " + ef.getId( ) );
			}
			count++;
		}
		return refTypeNode;
	}

	@Override
	public String codeGeneration() {
		
		String valList="";
		
		for(Node f : this.fields) {
			valList += f.codeGeneration(); //fa push dei valori sullo stack
		}
		
		for (int i=0; i < fields.size(); i++) {
			valList += ("lhp " + "\n"); //push hp
			valList += ("sw\n"); 
			valList += ("push 1\n" + "lhp\n" + "add\n" + "shp\n"); //hp++	
		}
		
		valList += (
				"push " + (entry.getOffset() + FOOLlib.MEMSIZE) + "\n" + // push DP
				"lw\n" +
				"lhp\n" +
				"sw\n" +
				"lhp\n" );

		return valList + ("push 1\n" + "lhp\n" + "add\n" + "shp\n");
	}

}
