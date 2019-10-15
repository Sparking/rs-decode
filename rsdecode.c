#include <stdlib.h>
#include <string.h>
#include "rsdecode.h"

int rsdecode(const struct generic_gf *field,unsigned int *received, unsigned int length, unsigned int twos)
{
    struct generic_gf_poly *poly;
    unsigned int *sync;
    unsigned char no_error = 1;

    poly = generic_gf_poly_create(field, received, length);
    if (poly == NULL)
        return -1;

    sync = (unsigned int *)malloc(sizeof(unsigned int) * twos);
    if (sync == NULL) {
        generic_gf_poly_release(poly);
        return -1;
    }
    memset(sync, 0, sizeof(unsigned int) * twos);

    for (unsigned int i = 0; i < twos; ++i) {
        unsigned int eval = generic_gf_poly_evaluateAt(poly,
                generic_gf_exp(field, i + field->generator_base));
        sync[twos - 1 - i] = eval;
        if (eval != 0)
            no_error = 0;
    }

    if (no_error) {
        generic_gf_poly_release(poly);
        free(sync);
        return 0;
    }

    generic_gf_poly_release(poly);
    free(sync);
    return -1;
}
