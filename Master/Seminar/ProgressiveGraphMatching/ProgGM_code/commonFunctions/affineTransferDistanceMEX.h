void MatMul(double* MatA, double* MatB, double* MatC, int type);
void MatInv(double* MatA, double* MatB);
double MatDet(double* MatA);

// Add on Functions
void MatMul(double* MatA, double* MatB, double* MatC, int type) {
    if (type == 1) {
        MatC[0] = MatA[0]*MatB[0]+MatA[1]*MatB[3];
        MatC[1] = MatA[0]*MatB[1]+MatA[1]*MatB[4];
        MatC[2] = MatA[0]*MatB[2]+MatA[1]*MatB[5]+MatA[2];
        MatC[3] = MatA[3]*MatB[0]+MatA[4]*MatB[3];
        MatC[4] = MatA[3]*MatB[1]+MatA[4]*MatB[4];
        MatC[5] = MatA[3]*MatB[2]+MatA[4]*MatB[5]+MatA[5];
    }
    else {
        MatC[0] = MatA[0]*MatB[0]+MatA[1]*MatB[1]+MatA[2];
        MatC[1] = MatA[3]*MatB[0]+MatA[4]*MatB[1]+MatA[5];
    }
}
void MatInv(double* MatA, double* MatB) {
    double detA = MatA[0]*MatA[4]-MatA[1]*MatA[3];
    MatB[0] = MatA[4]/detA;
    MatB[1] = -MatA[1]/detA;
    MatB[2] = (MatA[1]*MatA[5]-MatA[2]*MatA[4])/detA;
    MatB[3] = -MatA[3]/detA;
    MatB[4] = MatA[0]/detA;
    MatB[5] = (MatA[2]*MatA[3]-MatA[0]*MatA[5])/detA;
}
double MatDet(double* MatA) {
    return MatA[0]*MatA[4]-MatA[1]*MatA[3];
}