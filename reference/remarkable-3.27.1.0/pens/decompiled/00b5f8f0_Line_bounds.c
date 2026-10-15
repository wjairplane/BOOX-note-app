
undefined8 FUN_00b5f8f0(int param_1)

{
  int iVar1;
  float fVar2;
  float fVar3;
  float *pfVar4;
  float *pfVar5;
  float *pfVar6;
  float extraout_s0;
  double dVar7;
  float fVar8;
  float fVar9;
  float extraout_s10;
  float fVar10;
  float extraout_s11;
  float fVar11;
  float extraout_s12;
  double dVar12;
  double dVar13;
  undefined4 local_28;
  undefined4 uStack_24;
  
  if (*(int *)(param_1 + 0x14) == 0) {
    local_28 = 0;
    uStack_24 = 0;
  }
  else if ((*(double *)(param_1 + 0x38) <= 0.0) || (*(double *)(param_1 + 0x40) <= 0.0)) {
    pfVar5 = *(float **)(param_1 + 0x10);
    pfVar4 = (float *)(*(int *)(param_1 + 0x14) * 0xe + (int)pfVar5);
    fVar8 = DAT_00b5fa7c;
    fVar9 = DAT_00b5fa7c;
    fVar10 = DAT_00b5fa78;
    fVar11 = DAT_00b5fa78;
    dVar12 = DAT_00b5fa70;
    dVar13 = DAT_00b5fa70;
    if (pfVar4 != pfVar5) {
      do {
        fVar2 = *pfVar5;
        pfVar6 = (float *)((int)pfVar5 + 0xe);
        fVar3 = pfVar5[1];
        if (fVar8 != fVar2 && fVar8 < fVar2 == (NAN(fVar8) || NAN(fVar2))) {
          fVar8 = fVar2;
        }
        if (fVar10 < fVar2) {
          fVar10 = fVar2;
        }
        if (fVar9 != fVar3 && fVar9 < fVar3 == (NAN(fVar9) || NAN(fVar3))) {
          fVar9 = fVar3;
        }
        if (fVar11 < fVar3) {
          fVar11 = fVar3;
        }
        pfVar5 = pfVar6;
      } while (pfVar4 != pfVar6);
      dVar12 = (double)fVar9;
      dVar13 = (double)fVar8;
    }
    iVar1 = FUN_00b5f7fc(0x3f800000);
    dVar7 = (double)extraout_s0 * 0.5;
    *(double *)(iVar1 + 0x28) = dVar13 - dVar7;
    *(double *)(iVar1 + 0x30) = dVar12 - dVar7;
    *(double *)(iVar1 + 0x38) = (double)extraout_s11 + dVar7 + dVar7;
    *(double *)(iVar1 + 0x40) = (double)(extraout_s12 - extraout_s10) + dVar7 + dVar7;
    local_28 = *(undefined4 *)(iVar1 + 0x28);
    uStack_24 = *(undefined4 *)(iVar1 + 0x2c);
  }
  else {
    local_28 = *(undefined4 *)(param_1 + 0x28);
    uStack_24 = *(undefined4 *)(param_1 + 0x2c);
  }
  return CONCAT44(uStack_24,local_28);
}

