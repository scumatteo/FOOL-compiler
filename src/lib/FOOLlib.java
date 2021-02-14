package lib;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import ast.*;

public class FOOLlib {

    public static final int MEMSIZE = 10000;
	public static int typeErrors = 0;
	public static Map<String, String> superType = new HashMap<>();
	public static List<List<String>> dispatchTable = new ArrayList<>();

	/***
	 * Valuta se il tipo "a" � <= al tipo "b"
	 * Valuta co-varianza tra tipi di ritorno e controvarianza sui tipi del parametri.
	 * @param a
	 * @param b
	 * @return
	 */
	public static boolean isSubtype(Node a, Node b) {

		if ((a instanceof ArrowTypeNode) && (b instanceof ArrowTypeNode)) {
			if (((ArrowTypeNode) a).getParList().size() != ((ArrowTypeNode) b).getParList().size()) {
				return false;
			} else {
				if (!(((ArrowTypeNode) a).getRet().getClass().equals(((ArrowTypeNode) b).getRet().getClass())
						|| ((((ArrowTypeNode) a).getRet() instanceof BoolTypeNode)
								&& (((ArrowTypeNode) b).getRet() instanceof IntTypeNode)))) {
					return false;
				} else {
					for (int i = 0; i < ((ArrowTypeNode) a).getParList().size(); i++) {
						if (!((((ArrowTypeNode) a).getParList().get(i).getClass()
								.equals(((ArrowTypeNode) b).getParList().get(i).getClass())
								|| ((((ArrowTypeNode) a).getParList().get(i) instanceof IntTypeNode)
										&& (((ArrowTypeNode) b).getParList().get(i) instanceof BoolTypeNode))))) {
							return false;
						}
					}
					return true;
				}
			}
		}
		
		//a Empty --> b RefType TRUE
		//a Empty --> b != RefType FALSE
		if((a instanceof EmptyTypeNode)) {
			return  (b instanceof RefTypeNode);
		}
		//b Empty --> FALSE
		if(b instanceof EmptyTypeNode) {
			return false;
		}
		
		if ((a instanceof RefTypeNode) && (b instanceof RefTypeNode)) {
			String idFirst = ((RefTypeNode) a).getID();
			String idSecond = ((RefTypeNode) b).getID();
			
			//Risalgo a, se trovo un predecessore = b allora � sottotipo,
			//se arrivo alla classe padre di tutti senza trovare un uguaglianza verificata
			//concludo che a non � sottotipo di b
			while(!(idSecond.equals(idFirst)) && idFirst != null) {
				idFirst = superType.get(idFirst);
			}
			return (idFirst != null);
		}

		return a.getClass().equals(b.getClass()) || ((a instanceof BoolTypeNode) && (b instanceof IntTypeNode));
	}
	
	/***
	 *OTTIMIZZAZIONE 3) Type Checking per IF-THEN-ELSE 
	 * @param a
	 * @param b
	 * @return
	 */
	public static Node lowestCommonAncestor(Node a, Node b) {
		//se sono uguali ritorno 
		//Se uno dei due e empty ritorno l'altro
		if((a instanceof EmptyTypeNode))
			return  b; 
		
		if((b instanceof EmptyTypeNode))
			return a;
		
		if(a instanceof ArrowTypeNode && b instanceof ArrowTypeNode) {
			ArrowTypeNode arrowA = (ArrowTypeNode)a;
			ArrowTypeNode arrowB = (ArrowTypeNode)b;
			
			if(arrowA.getParList().size() != arrowB.getParList().size()) {
				return null;
			}
			Node lCommonAncestor = lowestCommonAncestor(arrowA.getRet(), arrowB.getRet());
			if(lCommonAncestor == null) {
				return lCommonAncestor;
			}
			List<Node> parList = new ArrayList<Node>();
			for(int i = 0; i < arrowA.getParList().size(); i++) {
				if(!(isSubtype(arrowA.getParList().get(i), arrowB.getParList().get(i))) && 
						!(isSubtype(arrowB.getParList().get(i), arrowA.getParList().get(i)))){
					return null;
				}
				else if(isSubtype(arrowA.getParList().get(i), arrowB.getParList().get(i))) {
					parList.add(arrowA.getParList().get(i));
				}
				else {
					parList.add(arrowB.getParList().get(i));
				}
				
			}
			return new ArrowTypeNode(parList, lCommonAncestor);
		}
		
		//Altrimenti devo cercare il lowest common ancestor, risalendo la catena:
		//se b e sottotipo di a -> return a
		//altrimenti risalgo il padre di a e controllo		
		if(a instanceof RefTypeNode && b instanceof RefTypeNode) {
            String idA = ((RefTypeNode)a).getID();        
            RefTypeNode parentA = new RefTypeNode(superType.get(idA));
            while(parentA != null) {
                if(isSubtype(b, parentA))
                    return parentA;
                    
                idA = superType.get(idA);
                parentA = new RefTypeNode(superType.get(idA));
            }		
		}
		
		//Int/Bool return il piu grande
        if( (a instanceof BoolTypeNode) && (b instanceof BoolTypeNode))
            return new BoolTypeNode();
        
        if( (a instanceof BoolTypeNode) && (b instanceof IntTypeNode)|| 
                (a instanceof IntTypeNode) && (b instanceof BoolTypeNode)||
                (a instanceof IntTypeNode) && (b instanceof IntTypeNode))
            return new IntTypeNode();

		//se non ho ancora restituito niente: null
		return null;
	}

	private static int labCount = 0;

	public static String freshLabel() {
		return "label" + (labCount++);
	}

	private static int funlabCount = 0;

	public static String freshFunLabel() {
		return "function" + (funlabCount++);
	}

	private static int methodlabCount = 0;
	
	public static String freshMethodLabel() {
		return "method" + (methodlabCount++);
	}
	
	private static String funCode = "";

	public static void putCode(String c) {
		funCode += "\n" + c; // aggiunge una linea vuota di separazione prima di funzione
	}

	public static String getCode() {
		return funCode;
	}

}
   

