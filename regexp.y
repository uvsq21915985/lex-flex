%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex();
int yyerror(char* s);

// Déclarations des fonctions
void programme(char* expression, char* mots);
char* duplication(char* source);
char* concatenation(char* left, char* right);
char* concatenate_strings(char* premier, char* suite);
char* print_reconnaissance(char* mot, char* mots);
char* print_union(char* left, char* right);
char* print_concatenation(char* left, char* right);
char* print_etoile(char* expression);
char* print_lettre(char LETTRE);

// Variable indiquant a<n> lors de l'écriture du script main.py
int n = 0;
%}

// Définition de l'union utilisée dans les types
%union {
    char lettre;
    char* code;
}

%token LETTRE EPSILON VIDE SDL PAR_OUVR PAR_FERM
%left ETOILE
%left CONCAT 
%left UNION

%type <lettre> LETTRE
%type <lettre> EPSILON
%type <lettre> VIDE

%type <code> programme
%type <code> expression
%type <code> mot
%type <code> reconnaissance

%start programme

%%
programme   : expression SDL reconnaissance     { programme($1, $3); };

expression  : expression UNION expression    { $$ = print_union($1, $3); }
            | expression CONCAT expression   { $$ = print_concatenation($1, $3);}
            | expression ETOILE              { $$ = print_etoile($1); }
            | PAR_OUVR expression PAR_FERM     { $$ = $2; }
            | LETTRE                            { $$ = print_lettre($1); }
            | EPSILON                           { $$ = print_lettre($1); }
            | VIDE                              { $$ = print_lettre($1); }
            ;

reconnaissance  : mot SDL reconnaissance    { $$ = print_reconnaissance($1, $3); }
                | mot SDL                   { $$ = print_reconnaissance($1, NULL); }
                | SDL                       {;}
                ;


mot     : LETTRE mot        { $$ = concatenation(&$1, $2); }
        | EPSILON mot       { $$ = concatenation(&$1, $2); }
        | VIDE mot          { $$ = concatenation(&$1, $2); }
        | LETTRE            { $$ = duplication(&$1); }
        | EPSILON           { $$ = duplication(&$1); }
        | VIDE              { $$ = duplication(&$1); }
        ;
%%

void programme(char* expression, char* mots) {
    FILE *fp = fopen("main.py", "w");
    if (fp == NULL) {
        printf("Le fichier main.py n'a pas pu être ouvert\n");
        exit(1);
    }
    fprintf(fp, "from automate import *\n\n%s\n", expression);
    free(expression);
    fprintf(fp, "a_final = a%d\nprint(a_final)\n%s", n-1, mots);
    free(mots);
    if (fclose(fp) == EOF) {
        printf("Erreur lors de la fermeture du flux\n");
        exit(1);        
    }
}

char* concatenate_strings(char* premier, char* suite) {
    size_t length = strlen(premier) + strlen(suite) + 1;
    char* buffer = malloc(sizeof(char)*length);
    
    // Gestion de l'échec d'allocation
    if (buffer == NULL) { return NULL; }
    strcpy(buffer, premier);
    strcat(buffer, suite);
    free(suite);
    return buffer;
}

char* print_reconnaissance(char* mot, char* mots) {
    size_t length = strlen(mot) + 30;
    char* buffer = malloc(sizeof(char)*length);

    // Gestion de l'échec d'allocation
    if (buffer == NULL) { return NULL; }
    if (mots == NULL) {
        sprintf(buffer, "print(reconnait(a_final,\"%s\"))\n", mot);
        return buffer;  
    }
    buffer = realloc(buffer, strlen(mot) + strlen(mots) + 30);
    sprintf(buffer, "print(reconnait(a_final,\"%s\"))\n%s", mot, mots);
    return buffer;
}

char* print_union(char* left, char* right) {
    size_t length = strlen(left) + strlen(right) + 30;
    char* buffer = malloc(sizeof(char)*length);

    // Gestion de l'échec d'allocation
    if (buffer == NULL) { return NULL; }
    sprintf(buffer, "%s%sa%d = union(a%d,a%d)\n", left, right, n, n-2, n-1);
        free(left); free(right);

    n ++;
    return buffer;
}

char* print_concatenation(char* left, char* right) {
    size_t length = strlen(left) + strlen(right) + 30;
    char* buffer = malloc(sizeof(char)*length);

    // Gestion de l'échec d'allocation
    if (buffer == NULL) { return NULL; }
    sprintf(buffer, "%s%sa%d = concatenation(a%d,a%d)\n", left, right, n, n-2, n-1);
    free(left); free(right);
    n ++;
    return buffer;
}

char* print_etoile(char* expression) {
    size_t length = strlen(expression) + 30;
    char* buffer = malloc(sizeof(char)*length);

    // Gestion de l'échec d'allocation
    if (buffer == NULL) { return NULL; }
    sprintf(buffer, "%sa%d = etoile(a%d)\n", expression, n, n-1);
    free(expression);
    n ++;
    return buffer;
}

char* print_lettre(char lettre) {
    char* buffer = malloc(sizeof(char));

    // Gestion de l'échec d'allocation
    if (buffer == NULL) { return NULL; }
    sprintf(buffer, "a%d = automate(\"%c\")\n", n, lettre);
    n++;
    return buffer;
}

char* duplication(char* source) {
    size_t length = strlen(source);
    char* buffer = malloc(length + 1); // +1 pour le caractère de fin de chaîne '\0'

    // Gestion de l'échec d'allocation
    if (buffer == NULL) { return NULL; }
    strcpy(buffer, source);
    return buffer;
}

char* concatenation(char* left, char* right) {
    // Alloue de la mémoire pour la nouvelle chaîne résultante
    char* buffer = malloc(strlen(left) + strlen(right) + 1);

    // Gestion de l'échec d'allocation
    if (buffer == NULL) { return NULL; }
    strcpy(buffer, left);
    strcat(buffer, right);
    free(right);
    return buffer;
}

int main() {
    yyparse();
    return 0;
}

int yyerror(char* s){
    return 1;
};
