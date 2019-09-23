%{
#include <iostream>
#include <sstream>
#include <string>
#include <unordered_map>
#include <vector> 
using std::string;
using std::getline;


#define YYSTYPE atributos

using namespace std;

typedef struct{

	string tipo;
	string nome;
	string valor;
} variable;

struct atributos
{
	string tipo;
	string label;
	string traducao;
};

int valorVar = 0;
unordered_map <string, variable> tabSym;
vector <string> tempVector;


int yylex(void);
void yyerror(string);
string genLabel();
string addVarToTabSym(string nomeDado, string conteudoVar, string tipoVar);
void implicitConversion(string variavel, string tipo0, string tipo1);
void addVarToTempVector(string nomeVar);
void printVector();
%}

%token TK_NUM
%token TK_MAIN TK_ID
%token TK_DEC_VAR TK_TIPO_INT TK_TIPO_FLOAT TK_TIPO_BOOL TK_TIPO_CHAR TK_CONV_FLOAT TK_CONV_INT
%token TK_CHAR TK_FLOAT
%token TK_FIM TK_ERROR

%start S

%left '+' '-'
%left '*' '/'
%left '(' ')'

%%

S 			: TK_TIPO_INT TK_MAIN '(' ')' BLOCO
			{
				cout << "/*Compilador Eva*/\n" << "#include <iostream>\n#include<string.h>\n#include<stdio.h>\nint main(void)\n{" <<endl;
				printVector();
				cout << $5.traducao << "\treturn 0;\n}" << endl;
			}
			;

BLOCO		: '{' COMANDOS '}'
			{
				$$.traducao = $2.traducao;
			}
			;

COMANDOS	: COMANDO COMANDOS
			{
				$$.traducao = $1.traducao + $2.traducao;
			}
			|
			{
				$$.traducao = "";
			}
			;

COMANDO 	: E ';'
			{
				$$ = $1;
			}
			| ATRIBUICAO ';'
			;

ATRIBUICAO 	: TK_DEC_VAR TK_ID TK_TIPO_CHAR '=' TK_CHAR
			{
				string nomeAuxID = addVarToTabSym($2.label, $5.traducao, "char");
				$$.traducao = "\t" + nomeAuxID + " = " + $5.traducao + ";\n";
				addVarToTempVector("\t" + nomeAuxID + ";\n");
			}

			| TK_DEC_VAR TK_ID TK_TIPO_INT '=' E
			{
				string nomeAuxID = addVarToTabSym($2.label, $5.traducao, "int");
				$$.traducao = $5.traducao + "\t" + nomeAuxID + " = " + $5.label + ";\n";
				addVarToTempVector("\t" + nomeAuxID + ";\n");
			}

			| TK_DEC_VAR TK_ID TK_TIPO_FLOAT '=' E
			{
				string nomeAuxID = addVarToTabSym($2.label, $5.traducao, "float");
				$$.traducao = $5.traducao + "\t" + nomeAuxID + " = " + $5.label + ";\n";
				addVarToTempVector("\t" + nomeAuxID + ";\n");
			}
			;

E 			: E '+' E
			{
				$$.label = genLabel();
				implicitConversion($$.label, tabSym[$1.label].tipo, tabSym[$3.label].tipo);
				addVarToTempVector("\t" + $1.label + ";\n");
				addVarToTempVector("\t" + $3.label + ";\n");
				cout << tabSym[$1.label].tipo << endl;
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " + " + $3.label + ";\n";
			}

			| E '-' E
			{
				$$.label = genLabel();
				implicitConversion($$.label, tabSym[$1.label].tipo, tabSym[$3.label].tipo); 
				addVarToTempVector("\t" + $1.label + ";\n");
				addVarToTempVector("\t" + $3.label + ";\n");			
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " - " + $3.label + ";\n";
			}

			| E '*' E
			{
				$$.label = genLabel();
				implicitConversion($$.label, tabSym[$1.label].tipo, tabSym[$3.label].tipo);
				addVarToTempVector("\t" + $1.label + ";\n");
				addVarToTempVector("\t" + $3.label + ";\n");
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " * " + $3.label + ";\n";
			}

			| E '/' E
			{
				$$.label = genLabel();
				$$.tipo = "float";
				addVarToTempVector("\t" + $1.label + ";\n");
				addVarToTempVector("\t" + $3.label + ";\n");
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " / " + $3.label + ";\n";
			}

			| '(' E ')'
			{
				$$.label = genLabel();
				addVarToTempVector("\t" + $2.label + ";\n");
				$$.traducao = $2.traducao + "\t" + $$.label + " = " + '(' + $2.label + ')' + ";\n";
			}

			| TK_NUM
			{
				$$.label = genLabel();
				addVarToTempVector("\t" + $1.label + ";\n");
				addVarToTabSym($$.label, $$.traducao, "int");
				$$.traducao = "\t" + $$.label + " = " + $1.traducao + ";\n";
			}

			| TK_FLOAT
		 	{
				$$.label = genLabel();
				addVarToTempVector("\t" + $1.label + ";\n");
				addVarToTabSym($$.label, $$.traducao, "float");
				$$.traducao = "\t" + $$.label + " = " + $1.traducao + ";\n";
		 	}

			| TK_ID
			{
				$$.label = genLabel();
				addVarToTempVector("\t" + $1.label + ";\n");
				addVarToTabSym($1.label, $1.traducao, $1.tipo);
				$$.traducao = "\t" + $$.label + " = " + $1.traducao + ";\n";
			}

			| TK_CHAR
			{
				$$.label = genLabel();
				addVarToTempVector("\t" + $1.label + ";\n");
				addVarToTabSym($$.label, $$.traducao, "char");
				$$.traducao = "\t" + $$.label + " = " + $1.traducao + ";\n";
			}
			;
%%

#include "lex.yy.c"

int yyparse();

int main( int argc, char* argv[] )
{

	yyparse();
	return 0;
}

void yyerror( string MSG )
{
	cout << MSG << endl;
	exit (0);
}

string genLabel(){

	std::string nomeVar = "temp";
	valorVar++;
	return nomeVar + to_string(valorVar);
}

string addVarToTabSym(string nomeDado, string conteudoVar, string tipoVar){

	unordered_map<string, variable>::const_iterator got = tabSym.find(nomeDado);
	string nomeGerado;

	if(got == tabSym.end()){

		variable Var;
		nomeGerado = genLabel();

		Var = {
				.tipo = tipoVar,
			   	.nome = nomeGerado,
				.valor = conteudoVar
			  };

		tabSym[nomeDado] = Var;
		cout << "adicionado na tabela de simbolos\n" << endl;
		return tabSym[nomeDado].nome;
	}

	else {

		cout << "encontrado na tabela de simbolos\n" << endl;
		return tabSym[nomeDado].nome;
	}

	return "";
}

void implicitConversion(string variavel, string tipo0, string tipo1)
{
	if (tipo0 == "int" && tipo1 == "float")
    {
    	cout << "convertendo int para float\n" << endl;
    	tabSym[variavel].tipo = "float";
    }

    else if(tipo1 == "int" && tipo0 == "float")
    {
    	cout << "convertendo int para float\n" << endl;
    	tabSym[variavel].tipo = "float";
    }

    else if(tipo0 == "float" && tipo1 == "float")
    {	
    	cout << "sem conversao, pois ambos sao float\n" << endl;
    	tabSym[variavel].tipo = "float";
    }

    else
    {
    	cout << "sem conversao, pois ambos sao inteiros\n" << endl;
    	tabSym[variavel].tipo = "int";
    }
}

void addVarToTempVector(string nomeVar)
{
	tempVector.push_back(nomeVar);
}

void printVector()
{
	for(auto i: tempVector)
	{
		cout << i;
	}

	cout << "\n\n" << endl;
}