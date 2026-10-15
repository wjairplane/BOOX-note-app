
void FUN_00b7cb4c(float param_1,float param_2,int param_3,undefined4 param_4,undefined4 param_5,
                 int param_6)

{
  undefined1 uVar1;
  undefined8 uVar2;
  undefined8 uVar3;
  float *pfVar4;
  float *pfVar5;
  int *piVar6;
  code *pcVar7;
  float *pfVar8;
  float *pfVar9;
  undefined8 uVar10;
  undefined4 extraout_s3;
  float fVar11;
  float fVar12;
  float fVar13;
  float in_s12;
  float fVar14;
  float fVar15;
  float fVar16;
  float fVar17;
  float fVar18;
  float fVar19;
  float fVar20;
  float fVar21;
  float fVar22;
  undefined8 uStack_b0;
  undefined4 uStack_98;
  undefined8 uStack_80;
  undefined4 uStack_70;
  undefined4 uStack_6c;
  float afStack_60 [2];
  undefined8 uStack_58;
  undefined4 uStack_50;
  undefined4 uStack_4c;
  undefined4 uStack_48;
  
  if ((in_s12 == param_1) && (*(float *)(param_3 + 0x40) == param_2)) {
    return;
  }
  if (*(char *)(param_3 + 0x14) != '\0') {
    fVar11 = *(float *)(param_3 + 0x40);
    fVar20 = *(float *)(param_3 + 0x3c);
    fVar16 = *(float *)(param_3 + 0xc);
    fVar12 = param_1 - fVar20;
    fVar15 = *(float *)(param_3 + 8);
    fVar14 = *(float *)(param_3 + 0x10);
    fVar19 = *(float *)(param_3 + 4) * 0.5;
    fVar13 = SQRT((param_2 - fVar11) * (param_2 - fVar11) + fVar12 * fVar12);
    fVar17 = (fVar11 - param_2) / fVar13;
    fVar18 = ABS(fVar16 * (fVar12 / fVar13) + fVar15 * fVar17) * *(float *)(param_3 + 4);
    if (fVar14 == fVar18 || fVar14 < fVar18 != (NAN(fVar14) || NAN(fVar18))) {
      fVar12 = *(float *)(param_3 + 0x44) * 0.5;
      fVar17 = fVar15 * fVar12;
      fVar12 = fVar16 * fVar12;
      fVar14 = fVar16 * fVar19;
      fVar15 = fVar15 * fVar19;
    }
    else {
      fVar17 = fVar17 * fVar14 * 0.5;
      fVar12 = (fVar12 / fVar13) * fVar14 * 0.5;
      fVar14 = fVar12;
      fVar15 = fVar17;
    }
    fVar18 = param_1 - fVar15;
    fVar16 = param_2 - fVar14;
    fVar22 = fVar11 - fVar12;
    fVar15 = fVar15 + param_1;
    fVar14 = fVar14 + param_2;
    fVar21 = fVar20 + fVar17;
    fVar11 = fVar11 + fVar12;
    fVar20 = fVar20 - fVar17;
    if (*(char *)(param_3 + 0x6c) == '\x02') {
      afStack_60[0] = fVar20;
      afStack_60[1] = fVar22;
      uStack_58._0_4_ = fVar18;
      uStack_58._4_4_ = fVar16;
      FUN_00b6aacc(*(undefined4 *)(param_3 + 0x78),*(undefined4 *)(param_3 + 0x7c),
                   *(undefined4 *)(param_3 + 0x88),*(undefined4 *)(param_3 + 0x8c),fVar20,fVar22,
                   fVar21,fVar11,param_3);
    }
    piVar6 = *(int **)(param_3 + 0x30);
    fVar13 = fVar13 + *(float *)(param_3 + 0x38);
    *(float *)(param_3 + 0x38) = fVar13;
    if (piVar6 == (int *)0x0) {
      uVar10 = 0;
      uStack_98 = 0;
    }
    else if (*(code **)(*piVar6 + 8) == (code *)&UNK_00b6cfd8) {
      uVar10 = CONCAT44(fVar19 * (float)piVar6[3],fVar13 * (float)piVar6[2]);
    }
    else {
      uVar10 = (**(code **)(*piVar6 + 8))(fVar13,fVar19,0x3f800000);
      if ((*(int **)(param_3 + 0x30) != (int *)0x0) &&
         (pcVar7 = *(code **)(**(int **)(param_3 + 0x30) + 8), pcVar7 != (code *)&UNK_00b6cfd8)) {
        (*pcVar7)(*(undefined4 *)(param_3 + 0x38),fVar19,0xbf800000);
      }
    }
    FUN_00b7be24(fVar20,fVar22,fVar18,fVar16,fVar21,fVar11,fVar15,fVar14,param_3,0);
    if (*(char *)(param_3 + 0x6c) == '\x01') {
      *(float *)(param_3 + 0xc4) = fVar20;
      *(float *)(param_3 + 200) = fVar22;
      *(float *)(param_3 + 0xcc) = fVar18;
      *(float *)(param_3 + 0xd0) = fVar16;
      *(float *)(param_3 + 0xd4) = fVar21;
      *(float *)(param_3 + 0xd8) = fVar11;
      *(float *)(param_3 + 0xdc) = fVar15;
      *(float *)(param_3 + 0xe0) = fVar14;
    }
    *(float *)(param_3 + 0x70) = fVar20;
    *(float *)(param_3 + 0x74) = fVar22;
    *(float *)(param_3 + 0x78) = fVar18;
    *(float *)(param_3 + 0x7c) = fVar16;
    *(float *)(param_3 + 0x80) = fVar21;
    *(float *)(param_3 + 0x84) = fVar11;
    *(float *)(param_3 + 0x88) = fVar15;
    *(float *)(param_3 + 0x8c) = fVar14;
    uStack_80._0_4_ = uStack_98;
    goto LAB_00b751ec;
  }
  fVar12 = param_1 - in_s12;
  fVar11 = *(float *)(param_3 + 0x40);
  fVar16 = *(float *)(param_3 + 4) * 0.5;
  fVar14 = *(float *)(param_3 + 0x44) * 0.5;
  fVar17 = SQRT(fVar12 * fVar12 + (param_2 - fVar11) * (param_2 - fVar11));
  fVar15 = (fVar11 - param_2) / fVar17;
  fVar13 = fVar15 * fVar14;
  fVar14 = (fVar12 / fVar17) * fVar14;
  fVar15 = fVar15 * fVar16;
  fVar12 = (fVar12 / fVar17) * fVar16;
  fVar18 = in_s12 + fVar13;
  fVar19 = fVar14 + fVar11;
  fVar21 = fVar15 + param_1;
  fVar20 = fVar12 + param_2;
  fVar13 = in_s12 - fVar13;
  fVar11 = fVar11 - fVar14;
  fVar15 = param_1 - fVar15;
  fVar12 = param_2 - fVar12;
  uStack_b0 = CONCAT44(fVar21,fVar19);
  uVar2 = CONCAT44(fVar12,fVar15);
  if (param_6 == 2) {
    FUN_00b6aacc(*(undefined4 *)(param_3 + 0x78),*(undefined4 *)(param_3 + 0x7c),
                 *(undefined4 *)(param_3 + 0x88),*(undefined4 *)(param_3 + 0x8c),fVar13,fVar11,
                 fVar18,fVar19,param_3);
  }
  piVar6 = *(int **)(param_3 + 0x30);
  fVar17 = fVar17 + *(float *)(param_3 + 0x38);
  *(float *)(param_3 + 0x38) = fVar17;
  if (piVar6 == (int *)0x0) {
    uVar10 = 0;
    uStack_80 = 0;
LAB_00b7ce10:
    uVar3 = 0;
  }
  else if (*(code **)(*piVar6 + 8) == (code *)&UNK_00b6cfd8) {
    uVar10 = CONCAT44(fVar16 * (float)piVar6[3],fVar17 * (float)piVar6[2]);
LAB_00b7cca0:
    uVar3 = CONCAT44(-(fVar16 * (float)piVar6[3]),fVar17 * (float)piVar6[2]);
  }
  else {
    uVar10 = (**(code **)(*piVar6 + 8))(fVar17,fVar16,0x3f800000);
    piVar6 = *(int **)(param_3 + 0x30);
    fVar17 = *(float *)(param_3 + 0x38);
    if (piVar6 == (int *)0x0) goto LAB_00b7ce10;
    if (*(code **)(*piVar6 + 8) == (code *)&UNK_00b6cfd8) goto LAB_00b7cca0;
    uStack_58 = (**(code **)(*piVar6 + 8))(fVar17,fVar16,0xbf800000);
    _uStack_4c = CONCAT44(uStack_48,extraout_s3);
    uVar3 = uStack_58;
  }
  FUN_00b7be24(fVar13,fVar11,fVar15,fVar12,fVar18,fVar19,fVar21,fVar20,param_3,0,
               (undefined4)uStack_80,uStack_80._4_4_,uVar10,(undefined4)uStack_80,uStack_80._4_4_,
               uVar3,uStack_70,uStack_6c);
  if (*(char *)(param_3 + 0x6c) == '\x01') {
    *(ulonglong *)(param_3 + 0xc4) = CONCAT44(fVar11,fVar13);
    *(undefined8 *)(param_3 + 0xcc) = uVar2;
    *(float *)(param_3 + 0xd4) = fVar18;
    *(float *)(param_3 + 0xd8) = fVar19;
    *(float *)(param_3 + 0xdc) = fVar21;
    *(float *)(param_3 + 0xe0) = fVar20;
  }
  *(ulonglong *)(param_3 + 0x70) = CONCAT44(fVar11,fVar13);
  *(undefined8 *)(param_3 + 0x78) = uVar2;
  *(float *)(param_3 + 0x80) = fVar18;
  *(undefined8 *)(param_3 + 0x84) = uStack_b0;
  *(float *)(param_3 + 0x8c) = fVar20;
LAB_00b751ec:
  afStack_60[0] = param_1;
  afStack_60[1] = param_2;
  uStack_50 = (int)uVar10;
  _uStack_4c = CONCAT44((undefined4)uStack_80,(int)((ulonglong)uVar10 >> 0x20));
  pfVar4 = afStack_60;
  pfVar5 = (float *)(param_3 + 0x3c);
  do {
    pfVar9 = pfVar5;
    pfVar8 = pfVar4;
    fVar17 = pfVar8[1];
    fVar13 = pfVar8[2];
    fVar11 = pfVar8[3];
    *pfVar9 = *pfVar8;
    pfVar9[1] = fVar17;
    pfVar9[2] = fVar13;
    pfVar9[3] = fVar11;
    pfVar4 = pfVar8 + 4;
    pfVar5 = pfVar9 + 4;
  } while (pfVar8 + 4 != (float *)&stack0xffffffd0);
  uVar1 = *(undefined1 *)((int)pfVar8 + 0x12);
  *(undefined2 *)(pfVar9 + 4) = *(undefined2 *)(pfVar8 + 4);
  *(undefined1 *)((int)pfVar9 + 0x12) = uVar1;
  return;
}

