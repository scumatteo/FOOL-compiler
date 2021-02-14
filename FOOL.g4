grammar FOOL;  

@header{
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import ast.*;
import lib.FOOLlib;
import java.util.Optional;
import java.util.stream.Collectors;
import java.util.HashSet;
}


@parser::members{
int stErrors=0;

// SYMBOL TABLE
private int nestingLevel = 0;
private List<HashMap<String,STentry>> symTable = new ArrayList<HashMap<String,STentry>>();
//livello ambiente con dichiarazioni piu' esterno � 0 (prima posizione ArrayList) invece che 1 (slides)
//il "fronte" della lista di tabelle � symTable.get(nestingLevel)

// CLS TABLE
private Map<String, HashMap<String,STentry>> classTable = new HashMap<>( );

private int offset = -2;
}

@lexer::members {
int lexicalErrors=0;
}

/********************************************************************************************************************
													PARSER RULES
********************************************************************************************************************/

////////////////////////////////////////////////////// PROGRAM //////////////////////////////////////////////////////

prog returns [Node ast] : {
		HashMap<String,STentry> hm = new HashMap<String,STentry> ();
    	symTable.add(hm);
	}
	(
		e=exp { $ast = new ProgNode( $e.ast ); } 
   	|	LET { List<Node> decList = new ArrayList<Node>( ); }
   			( 	
   				cls = clsList { decList.addAll( $cls.astList ); }
   				( clsdec = decList { decList.addAll( $clsdec.astList ); } )?
    		| 	dec = decList { decList.addAll( $dec.astList ); }				// TODO use questionmark ( '?' ) on cls??
    		)
    	IN e = exp { $ast = new ProgLetInNode( decList, $e.ast ); }    
	) { symTable.remove( nestingLevel ); }
    SEMIC EOF ;

/////////////////////////////////////////////////// LIST OF CLASS ///////////////////////////////////////////////////

clsList returns [List<Node> astList] : {
		$astList = new ArrayList<Node>( );

		HashMap<String,STentry> hm = symTable.get( nestingLevel );			// get nesting level table
	   	HashSet<String> hsRedefinition;
	} (
	CLASS clsID = ID {
		int fieldOffset = -1;
	   	int methodOffset = 0;
	   	
	   	hsRedefinition = new HashSet<>();
	   	
		ClassTypeNode clsT = new ClassTypeNode( );
		ClassNode cls = new ClassNode( clsT , $clsID.text);
		
		//Soph:Creo nuova STentry che mappa il nome della classe
		if ( hm.put( $clsID.text, new STentry(nestingLevel, clsT, offset--, false ) ) != null ) {
	        System.out.println("Class id "+$clsID.text+" at line "+$clsID.line+" already declared");
	    	stErrors++;
	    }
	    
      	//Incremento il nl
      	nestingLevel++;
      	HashMap<String,STentry> hmLevelClass = new HashMap<>();		
		symTable.add(hmLevelClass);
		
	} ( EXTENDS suID = ID {
		if ( classTable.get( $suID.text ) == null ) {
			System.out.println( "Class id " + $suID.text + " not found at line " + $suID.line );
    		stErrors++;
		} //TODO questo controllo??
		cls.setSuper( symTable.get( 0 ).get( $suID.text ) );
		ClassTypeNode superClassType = ( ClassTypeNode ) hm.get( $suID.text ).getType();
        fieldOffset = - 1 - superClassType.getAllFields( ).size( );
        methodOffset = superClassType.getAllMethods( ).size( );
        
        classTable.get( $suID.text ).forEach( (k, v) -> hmLevelClass.put( k, v ) );            // add super's elements ( fields and methods ) to the new virtual table
        FOOLlib.superType.put($clsID.text, $suID.text); 
		
	} )?
	LPAR (//CAMPI
		fID1 = ID COLON fT1 = type {
			FieldNode fieldNode = new FieldNode($fID1.text, $fT1.ast);
			cls.setField(fieldNode);
			
			hsRedefinition.add($fID1.text);
						
			if(cls.getSuper() != null){
				STentry val = hmLevelClass.get($fID1.text);
				if(val != null){
					fieldNode.setOffset(val.getOffset());	
					hmLevelClass.put($fID1.text, new STentry(nestingLevel, $fT1.ast, val.getOffset(), false));
					
				} else { //vall==null non ho trovato niente con lo stesso nome: NO OVERRIDING
					fieldNode.setOffset(fieldOffset);
					hmLevelClass.put($fID1.text, new STentry(nestingLevel, $fT1.ast, fieldOffset--, false));
				}
			} else {
				fieldNode.setOffset(fieldOffset);
				hmLevelClass.put($fID1.text, new STentry(nestingLevel, $fT1.ast, fieldOffset--, false));
			}
			
		} ( COMMA fIDn = ID COLON fTn = type {
			fieldNode = new FieldNode($fIDn.text, $fTn.ast);
			cls.setField(fieldNode);
			
			Boolean find = false; 
			for(String s : hsRedefinition){
				find = s.equals($fIDn.text) ? true : find;
			}
			if(find){
				System.out.println( "Redefinition of field " + $fIDn.text + " at line " + $fIDn.line );
    			stErrors++;
			} else {
				hsRedefinition.add($fIDn.text);
			}
			
			if(cls.getSuper() != null){
				STentry val = hmLevelClass.get($fIDn.text);
				if(val != null){
					fieldNode.setOffset(val.getOffset());
					hmLevelClass.put($fIDn.text, new STentry(nestingLevel, $fTn.ast, val.getOffset(), false));
				} else { //vall==null non ho trovato niente con lo stesso nome: NO OVERRIDING
					fieldNode.setOffset(fieldOffset);
					hmLevelClass.put($fIDn.text, new STentry(nestingLevel, $fTn.ast, fieldOffset--, false));
				}
			} else {
				fieldNode.setOffset(fieldOffset);
				hmLevelClass.put($fIDn.text, new STentry(nestingLevel, $fTn.ast, fieldOffset--, false));
			}
		})*
	)? RPAR
	CLPAR //METODI
		( {	hsRedefinition.clear(); }
			FUN mID = ID COLON mT = type {
				MethodNode methodNode = new MethodNode($mID.text, $mT.ast);
				cls.setMethod(methodNode);
				List<Node> parTypesMethod = new ArrayList<>();
				Boolean find = false; 
				for(String s : hsRedefinition){
					find = s.equals($mID.text) ? true : find;
				}
				if(find){
					System.out.println( "Redefinition of method " + $mID.text + " at line " + $mID.line );
    				stErrors++;
				} else {
					hsRedefinition.add($mID.text);
				}
				
				if(cls.getSuper() != null){
					STentry val = hmLevelClass.get($mID.text);
					if(val != null){
						methodNode.setOffset(val.getOffset());
						hmLevelClass.put($mID.text, new STentry(nestingLevel, new ArrowTypeNode( methodNode.getPars( ), $mT.ast ), val.getOffset(), true));
					} else { //vall==null non ho trovato niente con lo stesso nome: NO OVERRIDING
						methodNode.setOffset(methodOffset);
						hmLevelClass.put($mID.text, new STentry(nestingLevel, new ArrowTypeNode( methodNode.getPars( ), $mT.ast ), methodOffset++, true));
					}
				} else {
					methodNode.setOffset(methodOffset);
					hmLevelClass.put($mID.text, new STentry(nestingLevel, new ArrowTypeNode( methodNode.getPars( ), $mT.ast ), methodOffset++, true));
				}
				
		       	//creare una nuova hashmap per la symTable
		       	nestingLevel++;
		       	HashMap<String,STentry> hmn = new HashMap<String,STentry> ( );
		       	symTable.add( hmn );
		 	}
			LPAR { int paroffset = 1; }
				( pid1 = ID COLON pt1 = hotype {
		        	parTypesMethod.add( $pt1.ast );
		         	ParNode par1 = new ParNode( $pid1.text, $pt1.ast ); 				// create parameter node
		          	methodNode.addPar( par1 );                                 				// add him to parent function node
		           	if ( hmn.put( $pid1.text, new STentry( nestingLevel, $pt1.ast, paroffset++, false ) ) != null  ) { //aggiungo dich a hmn
		           		System.out.println( "Parameter id " + $pid1.text + " at line " + $pid1.line + " already declared" );
		        		stErrors++;
		        	}
		       	}
		      	( COMMA pid = ID COLON pt = hotype {
		      		parTypesMethod.add( $pt.ast );
		         	ParNode par = new ParNode( $pid.text, $pt.ast ); 				// create parameter node
		          	methodNode.addPar( par );                                 				// add him to parent function node
		           	if ( hmn.put( $pid.text, new STentry( nestingLevel, $pt.ast, paroffset++, false  ) ) != null ) { //aggiungo dich a hmn
		           		System.out.println( "Parameter id " + $pid.text + " at line " + $pid.line + " already declared" );
		        		stErrors++;
		        	}
		      	} )* )?
			RPAR 
		    ( 	{
			    	int oldOffset = offset;
			    	offset = -2;
		    	}
		    	LET d = decList IN  {
		    		methodNode.addDec( $d.astList ); 
			    	offset = oldOffset;
		    	}
		    )?
		    e = exp {
		    	methodNode.addBody( $e.ast );
		      	//rimuovere la hashmap corrente poiche esco dallo scope               
		       	symTable.remove( nestingLevel-- );    
		    } SEMIC
		)* 
		CRPAR { 
			$astList.add( cls ); 
			//Soph:Creo una VT per ora vuota
			HashMap<String, STentry> virtualTable = symTable.remove( nestingLevel-- );
			//Aggiungo alla classTable una nuova entry che mappa la VT appena creata
			classTable.put( $clsID.text, virtualTable );

			virtualTable.entrySet().stream().filter( e -> e.getValue().isMethod() ).sorted( (e1, e2) -> e1.getValue().getOffset() - e2.getValue().getOffset() ).forEach(e -> {
				//create new Method
				Node m = new MethodNode(e.getKey(), e.getValue().getType());
				clsT.setMethod(m);
			});
			
			virtualTable.entrySet().stream().filter( e -> !e.getValue().isMethod() ).sorted( (e1, e2) -> e2.getValue().getOffset() - e1.getValue().getOffset() ).forEach(e -> {
				Node f = new FieldNode(e.getKey(), e.getValue().getType());
				clsT.setField(f);
			} );
				
		} //TODO All'uscita rimuovo il livello corrente della SymTab
    )+ ;

//////////////////////////////////////////////// LIST OF DECLARATIONS ///////////////////////////////////////////////
//offset inizier� da offset delle classi solo per il nl 0
decList	returns [List<Node> astList] :
	{ $astList= new ArrayList<Node>( ); }      
	  ( (
            VAR i=ID COLON ht=hotype ASS e=exp 
            {VarNode v = new VarNode($i.text,$ht.ast,$e.ast);  
             $astList.add(v);   
             if($ht.ast instanceof ArrowTypeNode) // Se � di tipo funzionale usiamo un offset doppio. 
             									//Ci consente di memorizzare sia l'indirizzo della funzione sia l'FP (frame pointer) a questo AR (Activation Record).
          	{
             offset--;
          	}

             HashMap<String,STentry> hm = symTable.get(nestingLevel);
             if ( hm.put($i.text,new STentry(nestingLevel,$ht.ast,offset--, false)) != null  ) {
              System.out.println("Var id "+$i.text+" at line "+$i.line+" already declared");
              stErrors++; }  
            }
      |  
            FUN i=ID COLON t=type
              {//inserimento di ID nella symtable                              
              FunNode f = new FunNode($i.text,$t.ast);
          		$astList.add(f);
          		// Recuperiamo l'HashMap del livello attuale e vi aggiungiamo la FUN.
          		HashMap<String,STentry> hm = symTable.get(nestingLevel);
 				List<Node> parTypes = new ArrayList<Node>();
          		
                if ( hm.put($i.text,new STentry(nestingLevel,new ArrowTypeNode(parTypes,$t.ast),offset--, false)) != null) {
                	
                System.out.println("Fun id "+$i.text+" at line "+$i.line+" already declared");
                stErrors++; }
                offset--;  // perche e' funzionale
                //creare una nuova hashmap per la symTable
                nestingLevel++;
                HashMap<String,STentry> hmn = new HashMap<String,STentry> ();
                symTable.add(hmn);
                }
              LPAR {int paroffset=1;}
                (fid=ID COLON fty=hotype
                  { 
                  parTypes.add($fty.ast);
                  ParNode fpar = new ParNode($fid.text,$fty.ast); //creo nodo ParNode
                   if($fty.ast instanceof ArrowTypeNode )  // Se di tipo funzionale
               		paroffset++;
                  f.addPar(fpar);                                 //lo attacco al FunNode con addPar
                  if ( hmn.put($fid.text,new STentry(nestingLevel,$fty.ast,paroffset++, false )) != null ) { //aggiungo dich a hmn
                   System.out.println("Parameter id "+$fid.text+" at line "+$fid.line+" already declared");
                   stErrors++; }
                  }
                  (COMMA id=ID COLON ty=hotype
                    {
                    parTypes.add($ty.ast);
                    ParNode par = new ParNode($id.text,$ty.ast);
                    if($ty.ast instanceof ArrowTypeNode)
		              paroffset++;
                    f.addPar(par);
                    if ( hmn.put($id.text,new STentry(nestingLevel,$ty.ast,paroffset++, false )) != null ) {
                     System.out.println("Parameter id "+$id.text+" at line "+$id.line+" already declared");
                     stErrors++; }
                    }
                  )*
                )? 
              RPAR 
              (
		          	{ 
				    	int oldOffset = offset;
				    	offset = -2;
			    	}
			    	LET d = decList IN  {
			    		f.addDec( $d.astList ); 
				    	offset = oldOffset;
			    	}
              )? e=exp
              {f.addBody($e.ast);
               //rimuovere la hashmap corrente poiche esco dallo scope               
               symTable.remove(nestingLevel--);    
              }
      ) SEMIC
    )+ ;

/////////////////////////////////////////////////////// DATAS ///////////////////////////////////////////////////////

hotype  returns [Node ast]:
		t=type {$ast=$t.ast;}
  	|	a=arrow {$ast=$a.ast;} ;
	
type	returns [Node ast] :
		INT  {$ast = new IntTypeNode();}
	|	BOOL {$ast = new BoolTypeNode();} 
	| 	i = ID  {$ast = new RefTypeNode($i.text); } ;	

arrow 	returns [Node ast] : //implementato arrowTypeNode
	LPAR { List<Node> parList = new ArrayList<>(); }
	(h=hotype { parList.add($h.ast);} 
	(COMMA h1=hotype { parList.add($h1.ast);}
	)* )? RPAR ARROW t=type {
		$ast = new ArrowTypeNode(parList, $t.ast);
	} ;  

exp		returns [Node ast] :
	f=term { $ast= $f.ast; }
	(
 		PLUS l=term {$ast= new PlusNode ($ast,$l.ast);}
 	| 	MINUS l=term {$ast= new MinusNode($ast,$l.ast);} //Token minus d� conflitti
 	|	OR l=term {$ast= new OrNode($ast,$l.ast);} //token or
 	)* ;
 	
term	returns [Node ast] :
	f=factor {$ast= $f.ast;}
	(
		TIMES l=factor {$ast= new TimesNode ($ast,$l.ast);}
	|	DIV l=factor {$ast= new DivNode ($ast,$l.ast);}//token div 
	|	AND l=factor {$ast= new AndNode ($ast,$l.ast);} //token and
	)* ;

factor	returns [Node ast] :
	f=value {$ast= $f.ast;}
	(
		EQ l=value {$ast= new EqualNode ($ast,$l.ast);}
	|	GE l = value {$ast= new GreaterEqualNode ($ast,$l.ast);}//token >=
	|	LE l = value {$ast= new LessEqualNode ($ast,$l.ast);} //token <=
	)* ;	 	
 
value	returns [Node ast] :
		n=INTEGER {$ast= new IntNode(Integer.parseInt($n.text));}  
	| 	TRUE {$ast= new BoolNode(true);}  
	| 	FALSE {$ast= new BoolNode(false);}
	| 	NULL { $ast= new EmptyNode( ); }
	|	NEW clsID = ID {
			HashMap<String, STentry> virtualTable = classTable.get( $clsID.text );
			if ( virtualTable == null ) {
				System.out.println( "Class id " + $clsID.text + " not found at line " + $clsID.line );
        		stErrors++;
			}
			
			STentry classRef = symTable.get( 0 ).get( $clsID.text );
			if(classRef == null){
				System.out.println( "Class id " + $clsID.text + " doesn't exist at line " + $clsID.line );
        		stErrors++;
			}
			NewNode obj = new NewNode( symTable.get( 0 ).get( $clsID.text ), $clsID.text );
			
		}
		LPAR (
			e1 = exp {
				//FieldNode f = new FieldNode($e1.text, $e1.ast);
				obj.setField( $e1.ast );
			}
			( COMMA en = exp { 
				//f = new FieldNode($en.text, $en.ast);
				obj.setField( $en.ast );
				}
			 )*
		)? RPAR { $ast = obj; }
	| 	LPAR e=exp RPAR {$ast= $e.ast;}  
	| 	IF x=exp THEN CLPAR y=exp CRPAR 
		ELSE CLPAR z=exp CRPAR
	  		{$ast= new IfNode($x.ast,$y.ast,$z.ast);}	
	|	NOT LPAR e=exp RPAR {$ast= new NotNode($e.ast);}
	|	PRINT LPAR e=exp RPAR {$ast= new PrintNode($e.ast);}
	| 	i = ID {//cercare la dichiarazione
			HashMap<String,STentry> hm = symTable.get(0);
		
        	int nl=nestingLevel;
           	STentry entry=null;
           	while (nl>=0 && entry==null)
           		entry=(symTable.get(nl--)).get($i.text);

           	if (entry==null) {
             	System.out.println("Id "+$i.text+" at line "+$i.line+" not declared");
             	stErrors++; 
            }
            $ast = new IdNode($i.text, entry, nestingLevel);
	   	}
	   	( LPAR {List<Node> arglist = new ArrayList<Node>();}
		   	( a1 = exp { arglist.add( $a1.ast ); }
				( COMMA an = exp { arglist.add( $an.ast ); } )*
		   	)? RPAR { $ast = new CallNode( $i.text, entry, arglist, nestingLevel ); }
		|	DOT mID = ID {
				RefTypeNode reference = ( RefTypeNode ) entry.getType( );

				STentry classEntry = symTable.get( 0 ).get( reference.getID( ) );					// cls entry
				STentry methodEntry = classTable.get( reference.getID( ) ).get( $mID.text );		// method entry

				ClassCallNode clsCallNode = new ClassCallNode( entry, $mID.text, methodEntry, nestingLevel );
				$ast = clsCallNode;
			}
			LPAR (
				me1 = exp { clsCallNode.addPar( $me1.ast );	}
				( COMMA men = exp { clsCallNode.addPar( $men.ast ); } )*
			)? RPAR
		)? ;

/********************************************************************************************************************
													LEXER RULES
********************************************************************************************************************/

PLUS  	: '+' ;
MINUS   : '-' ;
TIMES   : '*' ;
DIV 	: '/' ;
LPAR	: '(' ;
RPAR	: ')' ;
CLPAR	: '{' ;
CRPAR	: '}' ;
SEMIC 	: ';' ;
COLON   : ':' ; 
COMMA	: ',' ;
DOT	    : '.' ; //TODO
OR	    : '||';
AND	    : '&&'; 
NOT	    : '!' ;
GE	    : '>=' ; 
LE	    : '<=' ; 
EQ	    : '==' ;	
ASS	    : '=' ;
TRUE	: 'true' ;
FALSE	: 'false' ;
IF	    : 'if' ;
THEN	: 'then';
ELSE	: 'else' ;
PRINT	: 'print' ;
LET     : 'let' ;	
IN      : 'in' ;	
VAR     : 'var' ;
FUN	    : 'fun' ; 
CLASS	: 'class' ;  //TODO
EXTENDS : 'extends' ;	//TODO
NEW 	: 'new' ;	//TODO
NULL    : 'null' ;	 
INT	    : 'int' ;
BOOL	: 'bool' ;
ARROW   : '->' ; 	//TODO
INTEGER : '0' | ('-')?(('1'..'9')('0'..'9')*) ; 
 
ID 	    : ('a'..'z'|'A'..'Z') ('a'..'z'|'A'..'Z'|'0'..'9')* ; 
 
WHITESP : (' '|'\t'|'\n'|'\r')+ -> channel(HIDDEN) ;

COMMENT : '/*' (.)*? '*/' -> channel(HIDDEN) ;

ERR     : . { System.out.println("Invalid char: "+ getText()); lexicalErrors++; } -> channel(HIDDEN); 
