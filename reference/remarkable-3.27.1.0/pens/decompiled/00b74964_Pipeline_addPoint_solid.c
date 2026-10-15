
void FUN_00b74964(float param_1,float param_2,undefined1 *param_3,undefined4 param_4,
                 undefined4 param_5,int param_6)

{
  undefined8 uVar1;
  code *pcVar2;
  undefined4 uVar3;
  float fVar4;
  float fVar5;
  float fVar6;
  float fVar7;
  float fVar8;
  float fVar9;
  float fVar10;
  float fVar11;
  float fVar12;
  float fVar13;
  float fVar14;
  float fVar15;
  undefined8 uStack_70;
  
  if (param_6 == 0) {
    uVar3 = *(undefined4 *)(param_3 + 0x38);
    fVar4 = *(float *)(param_3 + 4);
    if ((*(int **)(param_3 + 0x30) != (int *)0x0) &&
       (pcVar2 = *(code **)(**(int **)(param_3 + 0x30) + 8), pcVar2 != (code *)&UNK_00b6d030)) {
      (*pcVar2)(uVar3,fVar4 * 0.5,0x3f800000);
      fVar4 = *(float *)(param_3 + 4);
      uVar3 = *(undefined4 *)(param_3 + 0x38);
      if ((*(int **)(param_3 + 0x30) != (int *)0x0) &&
         (pcVar2 = *(code **)(**(int **)(param_3 + 0x30) + 8), pcVar2 != (code *)&UNK_00b6d030)) {
        (*pcVar2)(uVar3,fVar4 * 0.5,0xbf800000);
        fVar4 = *(float *)(param_3 + 4);
        uVar3 = *(undefined4 *)(param_3 + 0x38);
      }
    }
    uStack_70 = CONCAT44(uVar3,fVar4);
    *(ulonglong *)(param_3 + 0x3c) = CONCAT44(param_2,param_1);
    *(undefined8 *)(param_3 + 0x44) = uStack_70;
    param_3[0x4f] = *param_3;
    param_3[0x4e] = 1;
    *(undefined4 *)(param_3 + 0x74) = *(undefined4 *)(param_3 + 0x3c);
    param_3[0x50] = param_3[1];
    *(undefined4 *)(param_3 + 0x78) = *(undefined4 *)(param_3 + 0x40);
    *(undefined4 *)(param_3 + 0x7c) = *(undefined4 *)(param_3 + 0x44);
    *(undefined4 *)(param_3 + 0x80) = *(undefined4 *)(param_3 + 0x48);
    param_3[0x88] = param_3[1];
    *(undefined4 *)(param_3 + 0x84) = *(undefined4 *)(param_3 + 0x4c);
    return;
  }
  fVar4 = *(float *)(param_3 + 0x3c);
  if ((fVar4 != param_1) || (*(float *)(param_3 + 0x40) != param_2)) {
    if (param_3[0x14] != '\0') {
      fVar10 = *(float *)(param_3 + 0x40);
      fVar11 = *(float *)(param_3 + 0x3c);
      fVar5 = param_1 - fVar11;
      fVar8 = *(float *)(param_3 + 0xc);
      fVar7 = *(float *)(param_3 + 8);
      fVar6 = *(float *)(param_3 + 0x10);
      fVar13 = *(float *)(param_3 + 4) * 0.5;
      fVar12 = SQRT((param_2 - fVar10) * (param_2 - fVar10) + fVar5 * fVar5);
      fVar4 = (fVar10 - param_2) / fVar12;
      fVar9 = ABS(fVar8 * (fVar5 / fVar12) + fVar7 * fVar4) * *(float *)(param_3 + 4);
      if (fVar6 == fVar9 || fVar6 < fVar9 != (NAN(fVar6) || NAN(fVar9))) {
        fVar4 = fVar7 * *(float *)(param_3 + 0x44) * 0.5;
        fVar5 = fVar8 * *(float *)(param_3 + 0x44) * 0.5;
        fVar6 = fVar8 * fVar13;
        fVar7 = fVar7 * fVar13;
      }
      else {
        fVar4 = fVar4 * fVar6 * 0.5;
        fVar5 = (fVar5 / fVar12) * fVar6 * 0.5;
        fVar6 = fVar5;
        fVar7 = fVar4;
      }
      fVar9 = fVar10 - fVar5;
      fVar8 = param_2 - fVar6;
      fVar15 = param_1 - fVar7;
      fVar14 = fVar11 - fVar4;
      fVar7 = fVar7 + param_1;
      fVar6 = fVar6 + param_2;
      fVar11 = fVar11 + fVar4;
      fVar10 = fVar10 + fVar5;
      if (param_3[0x4e] == '\x02') {
        FUN_00b65ee4(*(undefined4 *)(param_3 + 0x5c),*(undefined4 *)(param_3 + 0x60),
                     *(undefined4 *)(param_3 + 0x6c),*(undefined4 *)(param_3 + 0x70),fVar14,fVar9,
                     fVar11,fVar10,param_3);
      }
      fVar4 = *(float *)(param_3 + 0x38);
      *(float *)(param_3 + 0x38) = fVar12 + fVar4;
      if ((*(int **)(param_3 + 0x30) != (int *)0x0) &&
         (pcVar2 = *(code **)(**(int **)(param_3 + 0x30) + 8), pcVar2 != (code *)&UNK_00b6d030)) {
        (*pcVar2)(fVar12 + fVar4,fVar13,0x3f800000);
        if ((*(int **)(param_3 + 0x30) != (int *)0x0) &&
           (pcVar2 = *(code **)(**(int **)(param_3 + 0x30) + 8), pcVar2 != (code *)&UNK_00b6d030)) {
          (*pcVar2)(*(undefined4 *)(param_3 + 0x38),fVar13,0xbf800000);
        }
      }
      FUN_00b653a4(fVar14,fVar9,fVar15,fVar8,fVar11,fVar10,fVar7,fVar6,param_3,0);
      if (param_3[0x4e] == '\x01') {
        *(float *)(param_3 + 0x8c) = fVar14;
        *(float *)(param_3 + 0x90) = fVar9;
        *(float *)(param_3 + 0x94) = fVar15;
        *(float *)(param_3 + 0x98) = fVar8;
        *(float *)(param_3 + 0x9c) = fVar11;
        *(float *)(param_3 + 0xa0) = fVar10;
        *(float *)(param_3 + 0xa4) = fVar7;
        *(float *)(param_3 + 0xa8) = fVar6;
      }
      *(float *)(param_3 + 0x54) = fVar14;
      *(float *)(param_3 + 0x58) = fVar9;
      *(float *)(param_3 + 0x5c) = fVar15;
      *(float *)(param_3 + 0x60) = fVar8;
      *(float *)(param_3 + 100) = fVar11;
      *(float *)(param_3 + 0x68) = fVar10;
      *(float *)(param_3 + 0x6c) = fVar7;
      *(float *)(param_3 + 0x70) = fVar6;
      *(ulonglong *)(param_3 + 0x3c) = CONCAT44(param_2,param_1);
      *(ulonglong *)(param_3 + 0x44) =
           CONCAT44(*(undefined4 *)(param_3 + 0x38),*(undefined4 *)(param_3 + 4));
      param_3[0x4f] = *param_3;
      param_3[0x4e] = 2;
      param_3[0x50] = param_3[1];
      return;
    }
    fVar5 = *(float *)(param_3 + 0x40);
    fVar6 = param_1 - fVar4;
    fVar11 = *(float *)(param_3 + 4) * 0.5;
    fVar10 = SQRT((param_2 - fVar5) * (param_2 - fVar5) + fVar6 * fVar6);
    fVar9 = (fVar5 - param_2) / fVar10;
    fVar7 = fVar9 * *(float *)(param_3 + 0x44) * 0.5;
    fVar8 = (fVar6 / fVar10) * *(float *)(param_3 + 0x44) * 0.5;
    fVar9 = fVar9 * fVar11;
    fVar6 = (fVar6 / fVar10) * fVar11;
    fVar12 = fVar4 + fVar7;
    fVar13 = fVar8 + fVar5;
    fVar15 = fVar9 + param_1;
    fVar14 = fVar6 + param_2;
    fVar4 = fVar4 - fVar7;
    fVar5 = fVar5 - fVar8;
    fVar9 = param_1 - fVar9;
    fVar6 = param_2 - fVar6;
    uVar1 = CONCAT44(fVar6,fVar9);
    if (param_6 == 2) {
      FUN_00b65ee4(*(undefined4 *)(param_3 + 0x5c),*(undefined4 *)(param_3 + 0x60),
                   *(undefined4 *)(param_3 + 0x6c),*(undefined4 *)(param_3 + 0x70),fVar4,fVar5,
                   fVar12,fVar13,param_3);
    }
    fVar7 = *(float *)(param_3 + 0x38);
    *(float *)(param_3 + 0x38) = fVar10 + fVar7;
    if ((*(int **)(param_3 + 0x30) != (int *)0x0) &&
       (pcVar2 = *(code **)(**(int **)(param_3 + 0x30) + 8), pcVar2 != (code *)&UNK_00b6d030)) {
      (*pcVar2)(fVar10 + fVar7,fVar11,0x3f800000);
      if ((*(int **)(param_3 + 0x30) != (int *)0x0) &&
         (pcVar2 = *(code **)(**(int **)(param_3 + 0x30) + 8), pcVar2 != (code *)&UNK_00b6d030)) {
        (*pcVar2)(*(undefined4 *)(param_3 + 0x38),fVar11,0xbf800000);
      }
    }
    FUN_00b653a4(fVar4,fVar5,fVar9,fVar6,fVar12,fVar13,fVar15,fVar14,param_3,0);
    if (param_3[0x4e] == '\x01') {
      *(ulonglong *)(param_3 + 0x8c) = CONCAT44(fVar5,fVar4);
      *(undefined8 *)(param_3 + 0x94) = uVar1;
      *(float *)(param_3 + 0x9c) = fVar12;
      *(float *)(param_3 + 0xa0) = fVar13;
      *(float *)(param_3 + 0xa4) = fVar15;
      *(float *)(param_3 + 0xa8) = fVar14;
    }
    *(ulonglong *)(param_3 + 0x54) = CONCAT44(fVar5,fVar4);
    *(undefined8 *)(param_3 + 0x5c) = uVar1;
    *(float *)(param_3 + 100) = fVar12;
    *(ulonglong *)(param_3 + 0x68) = CONCAT44(fVar15,fVar13);
    *(float *)(param_3 + 0x70) = fVar14;
    *(ulonglong *)(param_3 + 0x3c) = CONCAT44(param_2,param_1);
    *(ulonglong *)(param_3 + 0x44) =
         CONCAT44(*(undefined4 *)(param_3 + 0x38),*(undefined4 *)(param_3 + 4));
    param_3[0x4e] = 2;
    param_3[0x4f] = *param_3;
    param_3[0x50] = param_3[1];
  }
  return;
}

