%{
#include <assert.h>
#include <stdio.h>
#include <string.h>
#include "myparser.tab.h"
#include "cgen.h"
#include <math.h>

  int lineNum = 1;
%}


ID      [a-zA-Z_][0-9a-zA-Z_]*
DIGIT   [0-9]
NUMBER  [+-]?{DIGIT}{DIGIT}*
BOOL    ('true'|'false')
CHAR	[']([a-zA-Z_]|"\n"|"\t"|"\r"|"\\"|"\'"|"\""|"!"|"@"|"#"|"$"|"%"|"^"|"&"|"*"|"?"|":"|"."|"("|")"|"+"|"-"|"^"|"="|"/")[']   	
STRING  ["](.)*["]
DECIMAL ([+-]?"."{NUMBER})|([+-]?{NUMBER}("."{NUMBER}?)?)
REAL    {DECIMAL}([eE][+-]?{NUMBER})?


%%

if          	return KW_IF;
else	    	return KW_ELSE;
for  	    	return KW_FOR;
do		return KW_DO;
while		return KW_WHILE;
static		return KW_STATIC;
boolean		return KW_BOOLEAN;
integer		return KW_INTEGER;
char		return KW_CHAR;
real		return KW_REAL;
true		return KW_TRUE;
false		return KW_FALSE;
string		return KW_STRING;
void		return KW_VOID;
break		return KW_BREAK;
continue	return KW_CONTINUE;
return		return KW_RETURN;
begin		return KW_BEGIN;
end		return KW_END;
or		return KW_OR;
not		return KW_NOT;
and		return KW_AND;
mod		return KW_MOD;
readString	return KW_readString;
readInteger	return KW_readInteger;
readReal	return KW_readReal;
writeString	return KW_writeString;
writeInteger	return KW_writeInteger;
writeReal	return KW_writeReal;


{ID}        { yylval.str = strdup(yytext); return IDENTIFIER; }
{DIGIT}	    { yylval.str = strdup(yytext); return TK_DIGIT;}
{NUMBER}    { yylval.str = strdup(yytext); return POSINT; }
{DECIMAL}   { yylval.str = strdup(yytext); return TK_DECIMAL; }
{REAL}      { yylval.str = strdup(yytext); return REAL; }
{BOOL}	    { yylval.str = strdup(yytext); return TK_BOOL; }
{CHAR}      { yylval.str = strdup(yytext); return TK_CHAR;}
{STRING}    { yylval.str = strdup(yytext); return STRING;}


"+"         return '+';
"-"         return '-';
"*"         return '*';
"/"         return '/';
"="	    return '=';
"<"	    return '<';
">"	    return '>';
"<="	    return LESS_EQUAL;
">="	    return GREATER_EQUAL;
"!="	    return NOT_EQUAL;
"&&"	    return AND;
"||"	    return OR;
"!"	    return '!';


"("	    	return '(';
")"		return ')';
";"		return ';';
","		return ',';
"["		return '[';
"]"		return ']';

"//"[^\n]*  				/* eat line comments */
[/][*][^*]*[*]+([^*/][^*]*[*]+)*[/]     /* eat comments */ 

[ \r\t]+		/* eat whitespace */
\n 			 ++lineNum;

":="        { return ASSIGN ;}
.           { printf("Line %d Lexical Error: Unrecognized literal %s\n", lineNum, yytext); }
<<EOF>>     return TK_EOF;

%%

