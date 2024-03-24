%{
#include "regexp.tab.h"
%}
%%

"E"                     { return EPSILON; }
"O"                     { return VIDE; }
[a-z]                   { yylval.lettre = yytext[0]; return LETTRE; }

"("                     { return PAR_OUVR; }
")"                     { return PAR_FERM; }

"*"                     { return ETOILE; }
"."                     { return CONCAT; }
"+"                     { return UNION; }

[ \t]                   { ; } /* ignore les blancs et tabulations */
"\n"                    { return SDL; }
.                       { fprintf(stderr, "Caractère invalide : %s\n", yytext); }


%%