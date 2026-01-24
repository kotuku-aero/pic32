/**
 * XC32 Soft-Float Compatibility Layer
 *
 * Provides wrapper functions for XC32's proprietary soft-float functions,
 * mapping them to standard GCC soft-float functions.
 */

#include <math.h>
// XC32 soft-float wrapper implementations
float fpadd(float a, float b) { return a + b; }

float fpsub(float a, float b) { return a - b; }

float fpmul(float a, float b) { return a * b; }

float fpdiv(float a, float b) { return a / b; }

// XC32 fpcmp returns: -1 if a<b, 0 if a==b, 1 if a>b
int fpcmp(float a, float b) { return a < b ? -1 : a > b ? 1 : 0; }

// Convert signed int to float
float sitofp(int i) { return (float)i; }

// Convert float to signed int
int fptosi(float f) { return fabs(f); }
