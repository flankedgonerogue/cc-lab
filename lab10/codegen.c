#include <stdio.h>
#include <string.h>
#include <stdlib.h>

static void load_if_needed(const char *reg_name, const char *operand,
                           char *reg_val, int *reg_valid) {
    if (!(*reg_valid) || strcmp(reg_val, operand) != 0) {
        printf("LOAD %s, %s\n", reg_name, operand);
        strcpy(reg_val, operand);
        *reg_valid = 1;
    } else {
        printf("; LOAD skipped (%s already has %s)\n", reg_name, operand);
    }
}

static void translate_instruction(char *result, char *arg1, char *op, char *arg2,
                                  char *reg0, int *reg0_valid,
                                  char *reg1, int *reg1_valid) {
    printf("\n/* --- Generating Code for: %s = %s %s %s --- */\n", result, arg1, op, arg2);

    /* Task 1: Relational operators using CMP + JMP */
    if (strcmp(op, "<") == 0 || strcmp(op, ">") == 0 || strcmp(op, "==") == 0) {
        load_if_needed("R0", arg1, reg0, reg0_valid);
        load_if_needed("R1", arg2, reg1, reg1_valid);
        printf("CMP R0, R1\n");

        if (strcmp(op, "<") == 0) {
            printf("JMP< %s\n", result);
        } else if (strcmp(op, ">") == 0) {
            printf("JMP> %s\n", result);
        } else {
            printf("JMP== %s\n", result);
        }
        return;
    }

    /* STEP 1: LOAD arg1 into R0 */
    load_if_needed("R0", arg1, reg0, reg0_valid);

    /* STEP 2: OPERATE (use R1 for arg2 when needed) */
    if (strcmp(op, "+") == 0) {
        load_if_needed("R1", arg2, reg1, reg1_valid);
        printf("ADD R0, R1\n");
    } else if (strcmp(op, "-") == 0) {
        load_if_needed("R1", arg2, reg1, reg1_valid);
        printf("SUB R0, R1\n");
    } else if (strcmp(op, "*") == 0) {
        load_if_needed("R1", arg2, reg1, reg1_valid);
        printf("MUL R0, R1\n");
    } else if (strcmp(op, "/") == 0) {
        load_if_needed("R1", arg2, reg1, reg1_valid);
        printf("DIV R0, R1\n");
    } else if (strcmp(op, "=") == 0) {
        /* Direct assignment: no math op. */
    }

    /* STEP 3: STORE */
    printf("STORE %s, R0\n", result);

    /* R0 now holds the result value. */
    strcpy(reg0, result);
    *reg0_valid = 1;
}

int main(void) {
    char result[20], arg1[20], op[10], arg2[20];
    char reg0[20] = "";
    char reg1[20] = "";
    int reg0_valid = 0;
    int reg1_valid = 0;

    FILE *file = fopen("input.txt", "r");
    if (file == NULL) {
        printf("Error: input.txt not found. Please create the file first.\n");
        return 1;
    }

    printf("; #########################################\n");
    printf("; # AUTOMATED TARGET CODE GENERATOR       #\n");
    printf("; #########################################\n");

    while (fscanf(file, "%19s %19s %9s %19s", result, arg1, op, arg2) != EOF) {
        translate_instruction(result, arg1, op, arg2, reg0, &reg0_valid, reg1, &reg1_valid);
    }

    fclose(file);
    printf("\n; Code generation complete.\n");
    return 0;
}
