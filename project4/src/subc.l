/*                                                                          */
/* File Name    : subc.l                                                    */
/* Description  : a skeleton flex input                                     */
/*                                                                          */
/* Course       : Introduction to Compilers                                 */
/* Dept. of Electrical and Computer Engineering, Seoul National University  */
/*                                                                          */

%{
/* C Code Section */
/* Any code placed inside the brackets will be literally copied into the generated C file. */

#include "subc.h"
#include "subc.tab.h"
static int comment_depth = 0;
static int lineno = 1;
static char *filename;

%}

/* Definitions Section */
/* This section contains simple name definitions and declarations of start conditions. */

letter        [A-Za-z_]
digit         [0-9]
id            {letter}({letter}|{digit})*
integer_const ([1-9]{digit}*)|"0"
whitespace    [ \t]
special_char  \\[nt]

%x COMMENT

%%

  /* Rules Section */
  /* This section contains series of rules for recognizing tokens. */
  /* All comments in this section must be indented. */

  /* Keywords */
"int"                           { yylval.declptr = int_tdecl; return TYPE; }
"char"                          { yylval.declptr = char_tdecl; return TYPE; }
"struct"                        { return STRUCT; }
"NULL"                          { return SYM_NULL; }
"return"                        { return RETURN; }
"if"                            { return IF; }
"else"                          { return ELSE; }
"while"                         { return WHILE; }
"for"                           { return FOR; }
"break"                         { return BREAK; }
"continue"                      { return CONTINUE; }
"||"                            { return LOGICAL_OR; }
"&&"                            { return LOGICAL_AND; }
"<"                             { yylval.intval = OP_LESS; return RELOP; }
"<="                            { yylval.intval = OP_LESS_EQUAL; return RELOP; }
">"                             { yylval.intval = OP_GREATER; return RELOP; }
">="                            { yylval.intval = OP_GREATER_EQUAL; return RELOP; }
"=="                            { yylval.intval = OP_EQUAL; return EQUOP; }
"!="                            { yylval.intval = OP_NOT_EQUAL; return EQUOP; }
"++"                            { return INCOP; }
"--"                            { return DECOP; }
"->"                            { return STRUCTOP; }

  /* Identifiers */
{id}                            {
                                  struct id *entered  = enter(ID, yytext, yyleng);
                                  yylval.idptr = entered;
                                  return entered->tokenType;
                                }

  /* Integer constants */
{integer_const}                 {
                                  yylval.intval = atoi(yytext);
                                  return INTEGER_CONST;
                                }

  /* String variables */
\"({special_char}|[^\\\"\n])*\" {
                                  yylval.stringval = strndup(yytext+1, yyleng-2);
                                  return STRING;
                                }

  /* Character variables */
'({special_char}|[^\\'\n])'     {    
                                  yylval.charval = yytext[1];
                                  return CHAR_CONST;
                                }

  /* Operators */
","                             { return ','; }
";"                             { return yytext[0]; }
"%"                             { return '%'; }
"+"                             { return '+'; }
"-"                             { return '-'; }
"*"                             { return '*'; }
"/"                             { return '/'; }
"!"                             { return '!'; }
"("                             { return '('; } 
")"                             { return ')'; } 
"{"                             { return '{'; } 
"}"                             { return '}'; } 
"["                             { return '['; } 
"]"                             { return ']'; } 
"."                             { return '.'; }
"&"                             { return '&'; }
"="                             { return '='; }

  /* Whitespaces */
{whitespace}                    {;}


  /* Comment blocks */
<INITIAL,COMMENT>"/*"           {
                                  ++comment_depth;
                                  BEGIN (COMMENT);
                                }
<COMMENT>"*/"                   { 
                                  if(--comment_depth == 0) 
                                    BEGIN (INITIAL);
                                }
<COMMENT>.

  /* Tracking line numbers */
<*>\n                           { ++lineno; errflag = 0; }
.                               {;}

%%
   
/* User Code Section */
/* The user code section is simply copied to lex.yy.c verbatim. */

char *get_filename(void){
  return filename;
}

int get_lineno(void){
  return lineno;
}

int main(int argc, char* argv[]) {
  // I/O stream settings
  if (argc >= 3) {
    yyin = fopen(argv[1], "r");
    yyout = fopen(argv[2], "w");
    filename = strdup(argv[1]);
  }
  else if (argc >= 2) {
    yyin = fopen(argv[1], "r");
    yyout = stdout;
    filename = strdup(argv[1]);
  } else {
    yyin = stdin;
    yyout = stdout;
    filename = NULL;
  }

  if(!yyin || !yyout) {
    printf("Can't open input/output stream!\n");
    exit(1);
  }

  // init
  init_hash();
  init_scope();
  init_gen();
  
  yyparse();
  fclose(yyin);
  fclose(yyout);
  finish_scope();
  
  return 0;
}
