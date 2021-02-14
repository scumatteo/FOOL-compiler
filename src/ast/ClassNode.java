package ast;

import java.util.ArrayList;
import java.util.List;

import lib.FOOLlib;
import lib.TypeException;

/***
 * Definisce la mia struttura
 * @author Sophia Fantoni
 *
 */
public class ClassNode implements DecNode, Node {

	private STentry superEntry;
	private Node symType;  //ClassTypeNode
	private List<Node> fields;	//fieldNode
	private List<Node> methods;	//methodNode
	private String id;
	
	public ClassNode( Node type, String name ) {
		this.symType = type;
		this.superEntry = null;
		this.id = name;
		this.fields = new ArrayList<>();
		this.methods = new ArrayList<>();
	}
	
	public void setSuper( STentry superEntry ) {
		this.superEntry = superEntry;
	}
	
	public STentry getSuper() {
		return this.superEntry;
	}
		
	public void setField( Node field ) {
		this.fields.add( field );
	}
	
	public void setAllFields(List<Node> allFields) {
		this.fields = allFields;
	}

	public List<Node> getAllFields( ) {
		return fields;
	}
	
	public void setMethod( Node method ) {
		this.methods.add( method );
	}
	
	public void setAllMethods(List<Node> allMethods) {
		this.methods = allMethods;
	}
	
	public List<Node> getAllMethods( ) {
		return methods;
	}
	
	@Override
	public String toPrint(String s) {
		String fieldlstr = "";
		for (Node f : fields)
			fieldlstr += f.toPrint(s + "  ");
		String declstr = "";
		for (Node m : methods)
			declstr += m.toPrint(s + "  ");
		return s + "Class: " + this.id + /*" extends " + this.superEntry.get + */ "\n" + fieldlstr + declstr;
	}

	@Override
	public Node typeCheck() throws TypeException {
		for (Node m : methods)
			try {
				m.typeCheck();
			} catch (TypeException e) {
				System.out.println("Type checking error in a method: " + e.text);
			}
		
		if(superEntry != null) {
			ClassTypeNode classTypeNSuper = (ClassTypeNode) superEntry.getType();
			int minOffset = ((FieldNode)(classTypeNSuper.getAllFields().get(0))).getOffset();
			int maxOffset = ((FieldNode)(classTypeNSuper.getAllFields().get(classTypeNSuper.getAllFields().size()-1))).getOffset();
			int count = 0;
			
			for(Node f: fields) {
				if( ((FieldNode) f).getOffset() >= minOffset && ((FieldNode) f).getOffset() <= maxOffset) {
					if (!FOOLlib.isSubtype(((FieldNode)f).getSymType(), ((FieldNode)(classTypeNSuper.getAllFields().get(count))).getSymType()))
						throw new TypeException(" [ClassNode] Type check found a problem: \n Wrong overriding in field: " + ((FieldNode)f).getId());
				}
				count++;
			}
			
			minOffset = ((MethodNode)(classTypeNSuper.getAllMethods().get(0))).getOffset();
			maxOffset = ((MethodNode)(classTypeNSuper.getAllMethods().get(classTypeNSuper.getAllMethods().size()-1))).getOffset();
			count = 0;
			
			for(Node m: methods) {
				if( ((MethodNode) m).getOffset() >= minOffset && ((MethodNode) m).getOffset() <= maxOffset) {
					if (!FOOLlib.isSubtype(((MethodNode)m).getSymType(), ((MethodNode)(classTypeNSuper.getAllFields().get(count))).getSymType()))
						throw new TypeException(" [ClassNode] Type check found a problem: \n Wrong overriding in method: " + ((MethodNode)m).getID());
				}
				count++;
			}
		}
		
		return null; //TODO giusto?!?!?
	}

	@Override
	public String codeGeneration() {
		ArrayList<String> myDispatchTable = new ArrayList<>();
		FOOLlib.dispatchTable.add(myDispatchTable);
		String lab = "";
		int labOffset;
		int sizeMethod = 0;
		if ( superEntry != null ) {
			sizeMethod = ((ClassTypeNode)(this.superEntry.getType())).getAllMethods().size();
			List<String> superLabel = FOOLlib.dispatchTable.get(-2-superEntry.getOffset());
			
			for(String s : superLabel) {
				myDispatchTable.add(s);
			};
		}
		
		String labellist = "";
		
		for(Node m : this.methods) {
			((MethodNode)m).codeGeneration();
			lab = ((MethodNode)m).getLabel();
			labOffset = ((MethodNode)m).getOffset();
			
			if(labOffset < sizeMethod) { //check override
				myDispatchTable.remove(labOffset);
				myDispatchTable.add(labOffset, lab);
			} else {
				myDispatchTable.add(lab);	
			}
		}
		
		//Per ogni etichetta
		for (String s:myDispatchTable) {
			labellist += ("push " + s + "\n" ); //push label
			labellist += ("lhp\n"); //push hp
			labellist += ("sw\n");
			labellist += ("push 1\n" + "lhp\n" + "add\n" + "shp\n"); //hp++
		}

		return "lhp\n" + labellist;
	}

	@Override
	public Node getSymType() {
		return symType;
	}

}
