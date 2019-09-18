%{
#include <string>

%}

ESPACO [ \t]
DIGITO [0-9]
LETRA [A-Za-z_]

DELIM {ESPACO}+
NUM {DIGITO}+
REAL {NUM}+("."{NUM}+)?
CHAR \'({LETRA}|{NUM})\'
ID {LETRA}({LETRA}|{NUM})*
BOOL {"TRUE"|"FALSE"}

%%

"\n"		{}

{DELIM} 	{}

"main"		{return TK_MAIN;}

"int"		{return TK_TIPO_INT;}

"char"      {return TK_TIPO_CHAR;}

"float"     {return TK_TIPO_FLOAT;}

"var"       {return TK_DEC_VAR;}

"bool"		{ yylval.label = "bool"; yylval.traducao = yytext; return TK_TIPO_BOOL;}

[(){}[\];,=]	{ return *yytext; }

[+\-*/]		{ return *yytext; }


{CHAR}      { yylval.traducao = yytext; return TK_CHAR; }
{REAL}      { yylval.traducao = yytext; return TK_FLOAT;}
{NUM}		{ yylval.traducao = yytext; return TK_NUM;  }
{ID}		{ yylval.label = yytext; return TK_ID;      }

.			{ *yytext; }

%%
