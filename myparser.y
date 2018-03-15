%{
#define _GNU_SOURCE 
#include <stdarg.h>
  #include <stdio.h>
  #include <string.h>
  #include "cgen.h"
#include <stdlib.h>


//copied from cgen.c

  extern int yylex(void);
  extern int lineNum;
  

void ssopen(sstream* S)
{
	S->stream = open_memstream(& S->buffer, & S->bufsize);
}

char* ssvalue(sstream* S)
{
	fflush(S->stream);
	return S->buffer;
}

void ssclose(sstream* S)
{
	fclose(S->stream);
}


char* template(const char* pat, ...)
{
	sstream S;
	ssopen(&S);

	va_list arg;
	va_start(arg, pat);
	vfprintf(S.stream, pat, arg );
	va_end(arg);

	char* ret = ssvalue(&S);
	ssclose(&S);
	return ret;
}

/* Helper functions */


/*
	Report errors 
*/
 void yyerror (char const *pat, ...) {
 	va_list arg;
    fprintf (stderr, "line %d: ", lineNum);

    va_start(arg, pat);
    vfprintf(stderr, pat, arg);
    va_end(arg);
    
    yyerror_count++;
 }

int yyerror_count = 0;

const char* c_prologue = 
"#include \"fclib.h\"\n#include \"math.h\"\n#include <stdio.h>\n"
"\n"
;
 

char* s1="\"%d\"";
char* s2="\"%g\"";
char* s3="%";

%}

%union
{
  char* str;
}

%define parse.trace
%debug

%token <str> IDENTIFIER
%token <str> POSINT 
%token <str> REAL 
%token <str> STRING
%token <str> TK_DECIMAL
%token <str> TK_BOOL
%token <str> TK_CHAR
%token <str> TK_DIGIT
%token TK_EOF

%token ASSIGN

%token KW_IF
%token KW_ELSE
%token KW_FOR
%token KW_DO
%token KW_WHILE
%token KW_STATIC
%token KW_BOOLEAN
%token KW_INTEGER
%token KW_CHAR
%token KW_REAL
%token KW_STRING
%token KW_VOID
%token KW_BREAK
%token KW_CONTINUE
%token KW_RETURN
%token KW_BEGIN
%token KW_END
%token KW_AND
%token KW_OR
%token KW_NOT
%token KW_MOD
%token KW_TRUE
%token KW_FALSE

%token KW_readString
%token KW_readInteger
%token KW_readReal
%token KW_writeString
%token KW_writeInteger
%token KW_writeReal

%token LESS_EQUAL 
%token GREATER_EQUAL 
%token NOT_EQUAL 
%token AND 
%token OR 

%left '-' '+'
%left '*' '/' KW_MOD
%left '=' LESS_EQUAL GREATER_EQUAL NOT_EQUAL '<' '>'
%left KW_AND AND
%left KW_OR OR
%right '!' KW_NOT

%start input

%type <str> start_prog

%type <str> var_declaration
%type <str> var_d
%type <str> hooks
%type <str> basic_data_type
%type <str> ident

%type <str> func_declaration
%type <str> func_header
%type <str> func_header_conts
%type <str> func_body
%type <str> return
%type <str> func_body_conts

%type <str> expr
%type <str> compare_expr
%type <str> math_expr
%type <str> func_attr

%type <str> command
%type <str> command_list
%type <str> if_stmt
%type <str> for_stmt
%type <str> while_stmt
%type <str> do_while_stmt

%type <str> lib_func1
%type <str> lib_func2



%%

input : start_prog {puts(c_prologue);printf("%s\n", $1);};


start_prog: var_declaration func_declaration {$$ = template( "%s\n%s", $1,$2);}
| func_declaration {$$ = template( "%s", $1);}
| start_prog func_declaration {$$ = template( "%s\n%s", $1,$2);}
;

/*
Variables declarations
--------------------------------------------------------------------------------
*/

var_declaration :var_d ';' {$$ = template( "%s;\n", $1);}
  | KW_STATIC var_d ';'{$$ = template( "static %s;\n",$2);}
  |var_declaration var_d ';' {$$ = template( "%s%s;\n", $1, $2);}
  |var_declaration KW_STATIC var_d ';'{$$ = template( "%sstatic %s;\n",$1, $3);}
;

var_d : basic_data_type ident {$$ = template( "%s %s", $1, $2);}


hooks : '[' expr ']' {$$ = template( "[%s]", $2);}
  | hooks '[' expr ']' {$$ = template( "%s[%s]", $1, $3);}
;


basic_data_type : KW_INTEGER {$$ = template("int");}
  | KW_CHAR                  {$$ = template("char");}
  | KW_BOOLEAN               {$$ = template("int");}
  | KW_REAL                  {$$ = template("double");}
  | KW_STRING		     {$$ = template("char*");}
;

ident : ident ',' IDENTIFIER {$$ = template( "%s, %s", $1, $3);}
  | ident ',' IDENTIFIER ASSIGN expr {$$ = template( "%s, %s=%s", $1, $3, $5);}
  | IDENTIFIER {$$ = template( "%s", $1);}
  | IDENTIFIER hooks {$$ = template( "%s%s", $1,$2);}
  | IDENTIFIER ASSIGN expr{$$ = template( "%s=%s", $1, $3);}
;


/*
Functions
--------------------------------------------------------------------------
*/

func_declaration : func_header func_body {$$ = template( "\n%s\n%s\n", $1, $2);}
;

func_header : basic_data_type IDENTIFIER   '('func_header_conts')'    {$$ = template( "%s %s(%s)", $1, $2, $4);}
| KW_VOID IDENTIFIER  '('func_header_conts')'   {$$ = template( "void %s(%s)", $2, $4);}
| KW_VOID IDENTIFIER  '('')'   {$$ = template( "void %s()", $2);}
| basic_data_type IDENTIFIER   '('')'    {$$ = template( "%s %s()", $1, $2);}
;

func_header_conts :  func_header_conts ',' basic_data_type IDENTIFIER   {$$ = template( "%s, %s %s", $1, $3, $4);}
  | basic_data_type IDENTIFIER   {$$ = template( "%s %s", $1, $2);}
;

func_body : KW_BEGIN func_body_conts KW_END {$$ = template( " {\n%s\n}\n", $2);}
| KW_BEGIN KW_END {$$ = template( " {}\n");}
;

func_body_conts: command   {$$ = template( "%s\n", $1);}
| func_body_conts command  {$$ = template( "%s\n %s\n", $1, $2);}
;


//expresions

expr:
  POSINT {$$ = template( "%s", $1);}
| REAL {$$ = template( "%s", $1);}
| TK_BOOL {$$ = template( "%s", $1);}
| TK_CHAR {$$ = template( "%s", $1);}
| STRING  {$$ = template( "%s", $1);}
| TK_DIGIT {$$ = template( "%s", $1);}
| TK_DECIMAL {$$ = template( "%s", $1);}
| IDENTIFIER {$$ = template( "%s", $1);}
| KW_TRUE {$$ = template( "1");}
| KW_FALSE {$$ = template( "0");}
| '(' expr ')' {$$ = template( "(%s)",$2);}
| math_expr {$$ = template( "%s", $1);}
| '+' expr {$$ = template( "+%s", $2);}
| '-' expr {$$ = template( "-%s", $2);}
| compare_expr {$$ = $1;}
| IDENTIFIER '(' func_attr ')' {$$ = template( "%s(%s)", $1, $3);}
| IDENTIFIER '('  ')' {$$ = template( "%s()", $1);}
| lib_func1 {$$ = template( "%s", $1);}
| IDENTIFIER hooks {$$ = template( "%s%s", $1, $2);}
;

math_expr :  expr '*' expr {$$ = template( "%s*%s",$1 ,$3);}
| expr '/' expr {$$ = template( "%s/%s",$1 ,$3);}
| expr KW_MOD expr {$$ = template( "%s %s %s",$1, s3 ,$3);}
| expr '-' expr {$$ = template( "%s-%s",$1 ,$3);}
| expr '+' expr {$$ = template( "%s+%s",$1 ,$3);} 

compare_expr: expr '=' expr {$$ = template( "%s==%s",$1 ,$3);}
| expr '<' expr {$$ = template( "%s<%s",$1 ,$3);}
| expr '>' expr {$$ = template( "%s>%s",$1 ,$3);}
| expr LESS_EQUAL expr {$$ = template( "%s<=%s",$1 ,$3);}
| expr GREATER_EQUAL expr {$$ = template( "%s>=%s",$1 ,$3);}
| expr NOT_EQUAL expr {$$ = template( "%s!=%s",$1 ,$3);}
| expr AND expr {$$ = template( "%s&&%s",$1 ,$3);}
| expr KW_AND expr {$$ = template( "%s&&%s",$1 ,$3);}
| expr OR expr {$$ = template( "%s||%s",$1 ,$3);}
| expr KW_OR expr {$$ = template( "%s||%s",$1 ,$3);}
| '!' expr {$$ = template( "!%s",$2);}
| KW_NOT expr {$$ = template( "!%s",$2);}


//commands

command:  ';'              {$$ = template( ";");}
|  var_d ';' {$$ = template( "%s;\n", $1);}
|  KW_BEGIN command_list KW_END  {$$ = template( "{\n%s}", $2);}
|  IDENTIFIER ASSIGN expr ';' {$$ = template( "%s = %s;\n", $1, $3);}
|  IDENTIFIER hooks ASSIGN expr ';' {$$ = template( "%s%s = %s;\n", $1,$2, $4);}
|  if_stmt  {$$ = template( "%s\n", $1);}
|  for_stmt  {$$ = template( "%s\n", $1);}
|  while_stmt  {$$ = template( "%s\n", $1);}
|  do_while_stmt ';'{$$ = template( "%s;\n", $1);}
|  KW_BREAK ';' {$$ = template( "break;");}
|  KW_CONTINUE ';' {$$ = template( "continue;");}
|  return {$$ = template( "%s\n", $1);}
|  IDENTIFIER '(' func_attr ')' ';' {$$ = template( "%s(%s);\n", $1, $3);}
|  IDENTIFIER '(' ')' ';' {$$ = template( "%s();\n", $1);}
|  lib_func2 ';'{$$ = template( "%s;\n", $1);}
;

command_list : command command_list {$$ = template("%s\n%s\n",$1,$2);}               
|command {$$=$1;}              	
;


return: KW_RETURN ';' {$$ = template( " return ;\n");}
|  KW_RETURN expr ';' {$$ = template( " return %s ;\n", $2);}
;

func_attr:  expr {$$ = $1;}
| func_attr ',' expr {$$ = template( "%s, %s", $1, $3);}
;

if_stmt : 
  KW_IF '(' expr ')' command {$$ = template( "if (%s) \n%s", $3, $5);}
  | KW_IF '(' expr ')' command KW_ELSE command {$$ = template( "if (%s) \n%s\n else \n%s", $3, $5, $7);}
;

for_stmt: KW_FOR '(' IDENTIFIER ASSIGN expr ';' compare_expr ';' IDENTIFIER ASSIGN expr ')' command 
{$$ = template( "for (%s=%s;%s;%s=%s)\n%s", $3, $5, $7, $9, $11, $13);}
;

while_stmt: KW_WHILE '(' expr ')' command  {$$ = template( "while (%s)\n%s",$3, $5);}
;

do_while_stmt: KW_DO command KW_WHILE '(' expr ')'  {$$ = template( "do\n %s\n while (%s)",$2, $5);}

//Library Functions

lib_func1: KW_readString '('')'  { $$ = template("gets()");}
| KW_readInteger '('')'   { $$ = template("atoi(gets())");}
| KW_readReal '('')'   { $$ = template("atof(gets())");}
;

lib_func2 : KW_writeString  '(' expr ')'  {$$ = template( "puts(%s)",$3);}
| KW_writeInteger  '(' expr ')'  {$$ = template("printf(%s,%s)",s1,$3);}
| KW_writeReal    '(' expr ')'  {$$ = template( "printf(%s,%s)",s2,$3);}
;



%%
int main () {
  if ( yyparse() == 0 )
    printf("Accepted!\n");
  
}
