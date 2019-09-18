%{
#include <iostream>
#include <sstream>
#include <string>
#include <unordered_map>
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

int yylex(void);
void yyerror(string);
string genLabel();
string addVarToTabSym(string nomeDado, string conteudoVar, string tipoVar);
%}

%token TK_NUM
%token TK_MAIN TK_ID
%token TK_DEC_VAR TK_TIPO_INT TK_TIPO_FLOAT TK_TIPO_BOOL TK_TIPO_CHAR
%token TK_CHAR TK_FLOAT
%token TK_FIM TK_ERROR

%start S

%left '+' '-'
%left '*' '/'
%left '(' ')'

%%

S 			: TK_TIPO_INT TK_MAIN '(' ')' BLOCO
			{
				cout << "/*Compilador Eva*/\n" << "#include <iostream>\n#include<string.h>\n#include<stdio.h>\nint main(void)\n{\n" << $5.traducao << "\treturn 0;\n}" << endl;
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
				string nomeAuxID = addVarToTabSym($2.label, $5.traducao, $4.label);
				$$.traducao = "\t" + nomeAuxID + " = " + $5.traducao + ";\n";
			}

			| TK_DEC_VAR TK_ID TK_TIPO_INT '=' E
			{
				string nomeAuxID = addVarToTabSym($2.label, $5.traducao, $4.label);
				$$.traducao = $5.traducao + "\t" + nomeAuxID + " = " + $5.label + ";\n";
			}

			| TK_DEC_VAR TK_ID TK_TIPO_FLOAT '=' E
			{
				string nomeAuxID = addVarToTabSym($2.label, $5.traducao, $4.label);
				$$.traducao = $5.traducao + "\t" + nomeAuxID + " = " + $5.label + ";\n";
			}
			;

E 			: E '+' E
			{
				$$.label = genLabel();

				//REGRAS CONVERSAO
				if (tabSym[$1.label].tipo == "int" && tabSym[$3.label].tipo == "float")
			    {
			      $$.tipo = "float";
			    }

			    else if(tabSym[$3.label].tipo == "int" && tabSym[$1.label].tipo == "float")
			    {
			    	$$.tipo = "float";
			    }

			    else if(tabSym[$1.label].tipo == "float" && tabSym[$3.label].tipo == "float")
			    {
			    	$$.tipo = "float";
			    }

			    else
			    {
			    	$$.tipo = "int";
			    }
			    //FIM REGRAS CONVERSAO
				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " + " + $3.label + ";\n";
			}

			| E '-' E
			{
				$$.label = genLabel();

				if (tabSym[$1.label].tipo == "int" && tabSym[$3.label].tipo == "float")
			    {
			      $$.tipo = "float";
			    }

			    else if(tabSym[$3.label].tipo == "int" && tabSym[$1.label].tipo == "float")
			    {
			    	$$.tipo = "float";
			    }

			    else if(tabSym[$1.label].tipo == "float" && tabSym[$3.label].tipo == "float")
			    {
			    	$$.tipo = "float";
			    }

			    else
			    {
			    	$$.tipo = "int";
			    }

				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " - " + $3.label + ";\n";
			}

			| E '*' E
			{
				$$.label = genLabel();

				if (tabSym[$1.label].tipo == "int" && tabSym[$3.label].tipo == "float")
			    {
			      $$.tipo = "float";
			    }

			    else if(tabSym[$3.label].tipo == "int" && tabSym[$1.label].tipo == "float")
			    {
			    	$$.tipo = "float";
			    }

			    else if(tabSym[$1.label].tipo == "float" && tabSym[$3.label].tipo == "float")
			    {
			    	$$.tipo = "float";
			    }

			    else
			    {
			    	$$.tipo = "int";
			    }

				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " * " + $3.label + ";\n";
			}

			| E '/' E
			{
				$$.label = genLabel();
				$$.tipo = "float";

				$$.traducao = $1.traducao + $3.traducao + "\t" + $$.label + " = " + $1.label + " / " + $3.label + ";\n";
			}

			| '(' E ')'
			{
				$$.label = genLabel();
				$$.traducao = $2.traducao + "\t" + $$.label + " = " + '(' + $2.label + ')' + ";\n";
			}

			| TK_NUM
			{
				$$.label = genLabel();
				$$.traducao = "\t" + $$.label + " = " + $1.traducao + ";\n";
			}

			| TK_FLOAT
		 	{
			 $$.label = genLabel();
			 $$.traducao = "\t" + $$.label + " = " + $1.traducao + ";\n";
		 	}

			| TK_ID
			{
				$$.label = genLabel();
				$$.traducao = "\t" + $$.label + " = " + $1.traducao + ";\n";
			}

			| TK_CHAR
			{
				$$.label = genLabel();
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
		return tabSym[nomeDado].nome;
	}

	else {

		return tabSym[nomeDado].nome;
	}

	return "";
}
