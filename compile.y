%{
	#include <stdio.h>
	#include <iostream>
	#include <string>
	#include <map>
	#include <iterator>
	using namespace std;
	#include "y.tab.h"
	extern FILE *yyin;
	extern int yylex();
	void yyerror(string s);
	extern int linenum;// use variable linenum from the lex file
	int indent = 0;
	int sep=0;
	map<string,string> defValue;
	map<string,string> contentFunc;
	string finalOutput;
	string keepFunction;
	string temp;
	void printLine()
	{
			finalOutput+="";
	}

%}
%token <str> ANDOR IDENTIFIER INTEGER COMP MATH TYPERKW
%token IFRKW WHILERKW SEMICOLON OP CP OCB CCB  EQ EQSMALLER EQLARGER TYPERKW COMMA INTRSW MUL SUB DIV ADD
%type<str> operand condition_block  comparison_block  comparison type_def func_call


%union{
	char * str;
	int number;
}

%%

statements:
	statements statement
	|
	;


statement:
	condition_op condition_block openCurly statements closeCurly
	{
		printLine();
		finalOutput+="}\n";
		keepFunction+="}\n";
	}
	|
	type_def openCurly statements closeCurly
	{
		printLine();
		finalOutput+="}\n";
		keepFunction+="}\n";
		contentFunc.insert(make_pair($1,finalOutput)); //map
		temp = finalOutput;
		finalOutput="";
	}
	|
	function_body
	;

func_call:
	IDENTIFIER
	{
		if (defValue.find(string($1)) != defValue.end())
			$$=strdup((defValue[string($1)]).c_str());
		else
			$$=strdup($1);

	}
	;

function_body:
	int_print more_var SEMICOLON
	{
		printLine();
		finalOutput+=";\n";
		keepFunction+=";\n";

	}
	|
	int_print more_var EQ INTEGER
	{
		cout<<"yout cannot this at line  :"<<linenum<<endl;
	}
	|
	int_print var SEMICOLON
	{
		printLine();
		finalOutput+=";\n";
		keepFunction+=";\n";
	}
	|
	assignment_math SEMICOLON
	{
		printLine();
		finalOutput+=";\n";
		keepFunction+=";\n";
	}
	|
	func_call OP CP SEMICOLON
	{
		if(contentFunc.find($1) != contentFunc.end())
		{
			finalOutput+=contentFunc[$1];
		}
		else
		{
			cout<<"error: function "<<$1<<" does not exists"<<endl;
			sep++;
		}

	}
	;



type_def:
	TYPERKW IDENTIFIER OP CP
	{


		if (defValue.find(string($2)) != defValue.end())
			$$=strdup((defValue[string($2)]).c_str());
		else
			$$=strdup($2);



	}
	;










assignment_math:
	assignment_op assignment_math
	|
	;


assignment_op:

	MUL
	{
		printLine();
		finalOutput+="*";
		keepFunction+="*";
	}
	|
	ADD
	{
		printLine();
		finalOutput+="+";
		keepFunction+="+";
	}
	|
	SUB
	{
		printLine();
		finalOutput+="-";
		keepFunction+="-";
	}
	|
	DIV
	{
		printLine();
		finalOutput+="/";
		keepFunction+="/";
	}
	|
  EQ
	{
		printLine();
		finalOutput+="=";
		keepFunction+="=";
	}
	|
	operand
	{
		printLine();
		finalOutput+=string($1);
		keepFunction+=string($1);
	}
	;


more_var:
	more_var COMMA var
	{
		finalOutput+=",";
		keepFunction+=",";
		printLine();

	}
	|
	var
	{
		finalOutput+=",";
		keepFunction+=",";
		printLine();
	}

	;

var:
	IDENTIFIER
	{
		finalOutput+=string($1);
		keepFunction+=string($1);

	}
	;


int_print:
	INTRSW
	{
		finalOutput+="int ";
		keepFunction+="int ";

	}
	;


condition_block:
	OP comparison_block CP
	{
		finalOutput+="( "+ string($2) + " )\n";
		finalOutput+="{\n";
		keepFunction+="( "+ string($2) + " )\n";
		keepFunction+="{\n";
	}
	;

comparison_block:
	comparison_block ANDOR comparison
	{
		string combined = string($1)+ string($2) + string($3);
		$$ = strdup(combined.c_str());
	}
	|
	comparison
	{
		$$ = strdup($1);
	}
	;

comparison:
	operand COMP operand;
	{
		string combined = string($1) +" "+ string($2) +" "+ string($3);
		$$ = strdup(combined.c_str());
	}
;
condition_op:
	IFRKW {
		printLine();
		finalOutput+="if";
		keepFunction+="if";
	}
	|
	WHILERKW{
		printLine();
		finalOutput+="while";
		keepFunction+="while";
	}
	;
operand:
	IDENTIFIER {
  	if (defValue.find(string($1)) != defValue.end())
			$$=strdup((defValue[string($1)]).c_str());
		else
			$$=strdup($1);
	}
	|
	INTEGER {$$=strdup($1);}
	;

openCurly:
	OCB
	;
closeCurly:
	CCB
	;
%%
void yyerror(string s){

		cerr<<"Error at line: "<<linenum<<endl;
}
int yywrap(){
	return 1;
}
int main(int argc, char *argv[])
{
    /* Call the lexer, then quit. */
    yyin=fopen(argv[1],"r");
    yyparse();
    fclose(yyin);
		if(sep == 0)
		{
			cout<<"void main()"<<endl;
			cout<<"{"<<endl;
			cout<<contentFunc["main"]<<endl;
		}

		// for (auto itr = contentFunc.begin(); itr != contentFunc.end(); ++itr) {
    //     cout
    //          << itr->second << '\n';
    // }
		// cout<<"------------"<<endl;

    return 0;
}
