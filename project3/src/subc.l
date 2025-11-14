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
float_const   {integer_const}(\.{digit}*)?

%x COMMENT

%%

  /* Rules Section */
  /* This section contains series of rules for recognizing tokens. */
  /* All comments in this section must be indented. */

  /* Keywords */
"int" | "char"                  { yylval.stringval = strdup(yytext); return TYPE; }
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
"<"|"<="|">"|">="               { yylval.stringval = strdup(yytext); return RELOP; }
"=="|"!="                       { yylval.stringval = strdup(yytext); return EQUOP; }
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

{float_const}                   {
                                  sscanf(yytext, "%lf", &yylval.floatval);
                                  return FLOAT_CONST;
                                }

  /* String variables */
\"({special_char}|[^\\\"\n])*\" {
                                  yylval.stringval = yytext;
                                  return STRING;
                                }

  /* Character variables */
'({special_char}|[^\\'\n])'     {    
                                  yylval.stringval = yytext;
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
<*>\n                           { ++lineno; }
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
  // init
  init_hash();
  init_scope();
  init_type();

  // I/O stream settings
  if (argc >= 2) {
    yyin = fopen(argv[1], "r");
    filename = strdup(argv[1]);
  } else {
    yyin = stdin;
    filename = NULL;
  }

  if(!yyin) {
    printf("Can't open input stream!\n");
    exit(1);
  }
  
  yyparse();
  fclose(yyin);
  
  return 0;
}
