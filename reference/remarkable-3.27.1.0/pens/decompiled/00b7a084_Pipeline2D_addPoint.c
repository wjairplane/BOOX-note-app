
void FUN_00b7a084(float param_1,float param_2,undefined1 *param_3)

{
  undefined1 uVar1;
  undefined4 *puVar2;
  undefined4 uVar3;
  undefined4 *puVar4;
  undefined8 *puVar5;
  undefined8 *puVar6;
  undefined4 uVar7;
  undefined4 uVar8;
  undefined8 uVar9;
  undefined8 uVar10;
  undefined8 uVar11;
  float fVar12;
  float fVar13;
  float fVar14;
  float fVar15;
  float fVar16;
  float fVar17;
  float fVar18;
  float fVar19;
  float fVar20;
  float fVar21;
  float fVar22;
  float fVar23;
  
  if (param_3[0x5c] == '\0') {
    uVar8 = *(undefined4 *)(param_3 + 0x38);
    fVar12 = *(float *)(param_3 + 4);
    if (*(int **)(param_3 + 0x30) == (int *)0x0) {
      uVar9 = 0;
      uVar10 = 0;
    }
    else {
      uVar9 = (**(code **)(**(int **)(param_3 + 0x30) + 8))(uVar8,fVar12 * 0.5,0x3f800000);
      fVar12 = *(float *)(param_3 + 4);
      uVar8 = *(undefined4 *)(param_3 + 0x38);
      if (*(int **)(param_3 + 0x30) == (int *)0x0) {
        uVar10 = 0;
      }
      else {
        uVar10 = (**(code **)(**(int **)(param_3 + 0x30) + 8))(uVar8,fVar12 * 0.5,0xbf800000);
        fVar12 = *(float *)(param_3 + 4);
        uVar8 = *(undefined4 *)(param_3 + 0x38);
      }
    }
    *(ulonglong *)(param_3 + 0x3c) = CONCAT44(param_2,param_1);
    *(ulonglong *)(param_3 + 0x44) = CONCAT44(uVar8,fVar12);
    *(undefined8 *)(param_3 + 0x4c) = uVar9;
    *(undefined8 *)(param_3 + 0x54) = uVar10;
    param_3[0x5d] = *param_3;
    param_3[0x5c] = 1;
    param_3[0x5e] = param_3[1];
    puVar2 = (undefined4 *)(param_3 + 0x80);
    puVar6 = (undefined8 *)(param_3 + 0x3c);
    do {
      puVar5 = puVar6;
      puVar4 = puVar2;
      puVar6 = puVar5 + 2;
      uVar7 = *(undefined4 *)((int)puVar5 + 4);
      uVar8 = *(undefined4 *)(puVar5 + 1);
      uVar3 = *(undefined4 *)((int)puVar5 + 0xc);
      *puVar4 = *(undefined4 *)puVar5;
      puVar4[1] = uVar7;
      puVar4[2] = uVar8;
      puVar4[3] = uVar3;
      puVar2 = puVar4 + 4;
    } while (puVar6 != (undefined8 *)(param_3 + 0x5c));
    uVar1 = *(undefined1 *)((int)puVar5 + 0x12);
    *(undefined2 *)(puVar4 + 4) = *(undefined2 *)puVar6;
    *(undefined1 *)((int)puVar4 + 0x12) = uVar1;
    return;
  }
  fVar12 = *(float *)(param_3 + 0x3c);
  if ((fVar12 != param_1) || (*(float *)(param_3 + 0x40) != param_2)) {
    if (param_3[0x14] != '\0') {
      fVar18 = *(float *)(param_3 + 0x40);
      fVar19 = *(float *)(param_3 + 0x3c);
      fVar13 = param_1 - fVar19;
      fVar16 = *(float *)(param_3 + 0xc);
      fVar15 = *(float *)(param_3 + 8);
      fVar14 = *(float *)(param_3 + 0x10);
      fVar21 = *(float *)(param_3 + 4) * 0.5;
      fVar20 = SQRT((param_2 - fVar18) * (param_2 - fVar18) + fVar13 * fVar13);
      fVar12 = (fVar18 - param_2) / fVar20;
      fVar17 = ABS(fVar16 * (fVar13 / fVar20) + fVar15 * fVar12) * *(float *)(param_3 + 4);
      if (fVar14 == fVar17 || fVar14 < fVar17 != (NAN(fVar14) || NAN(fVar17))) {
        fVar12 = fVar15 * *(float *)(param_3 + 0x44) * 0.5;
        fVar13 = fVar16 * *(float *)(param_3 + 0x44) * 0.5;
        fVar14 = fVar16 * fVar21;
        fVar15 = fVar15 * fVar21;
      }
      else {
        fVar12 = fVar12 * fVar14 * 0.5;
        fVar13 = (fVar13 / fVar20) * fVar14 * 0.5;
        fVar14 = fVar13;
        fVar15 = fVar12;
      }
      fVar17 = param_1 - fVar15;
      fVar16 = param_2 - fVar14;
      fVar15 = fVar15 + param_1;
      fVar14 = fVar14 + param_2;
      fVar22 = fVar18 + fVar13;
      fVar23 = fVar19 + fVar12;
      fVar19 = fVar19 - fVar12;
      fVar18 = fVar18 - fVar13;
      if (param_3[0x5c] == '\x02') {
        FUN_00b6a3e4(*(undefined4 *)(param_3 + 0x68),*(undefined4 *)(param_3 + 0x6c),
                     *(undefined4 *)(param_3 + 0x78),*(undefined4 *)(param_3 + 0x7c),fVar19,fVar18,
                     fVar23,fVar22,param_3);
      }
      fVar12 = *(float *)(param_3 + 0x38);
      *(float *)(param_3 + 0x38) = fVar20 + fVar12;
      uVar9 = CONCAT44(DAT_00b7a080,DAT_00b7a080);
      uVar10 = uVar9;
      if (*(int **)(param_3 + 0x30) != (int *)0x0) {
        uVar9 = (**(code **)(**(int **)(param_3 + 0x30) + 8))(fVar20 + fVar12,fVar21,0x3f800000);
        uVar10 = CONCAT44(DAT_00b7a080,DAT_00b7a080);
        if (*(int **)(param_3 + 0x30) != (int *)0x0) {
          uVar10 = (**(code **)(**(int **)(param_3 + 0x30) + 8))
                             (*(undefined4 *)(param_3 + 0x38),fVar21,0xbf800000);
        }
      }
      FUN_00b797d8(fVar19,fVar18,fVar17,fVar16,fVar23,fVar22,fVar15,fVar14,param_3,0);
      if (param_3[0x5c] == '\x01') {
        *(float *)(param_3 + 0xa4) = fVar19;
        *(float *)(param_3 + 0xa8) = fVar18;
        *(float *)(param_3 + 0xac) = fVar17;
        *(float *)(param_3 + 0xb0) = fVar16;
        *(float *)(param_3 + 0xb4) = fVar23;
        *(float *)(param_3 + 0xb8) = fVar22;
        *(float *)(param_3 + 0xbc) = fVar15;
        *(float *)(param_3 + 0xc0) = fVar14;
      }
      *(float *)(param_3 + 0x60) = fVar19;
      *(float *)(param_3 + 100) = fVar18;
      *(float *)(param_3 + 0x68) = fVar17;
      *(float *)(param_3 + 0x6c) = fVar16;
      *(float *)(param_3 + 0x70) = fVar23;
      *(float *)(param_3 + 0x74) = fVar22;
      *(float *)(param_3 + 0x78) = fVar15;
      *(float *)(param_3 + 0x7c) = fVar14;
      *(ulonglong *)(param_3 + 0x3c) = CONCAT44(param_2,param_1);
      *(ulonglong *)(param_3 + 0x44) =
           CONCAT44(*(undefined4 *)(param_3 + 0x38),*(undefined4 *)(param_3 + 4));
      *(undefined8 *)(param_3 + 0x4c) = uVar9;
      *(undefined8 *)(param_3 + 0x54) = uVar10;
      param_3[0x5c] = 2;
      param_3[0x5d] = *param_3;
      param_3[0x5e] = param_3[1];
      return;
    }
    fVar14 = param_1 - fVar12;
    fVar13 = *(float *)(param_3 + 0x40);
    fVar18 = *(float *)(param_3 + 4) * 0.5;
    fVar19 = SQRT(fVar14 * fVar14 + (param_2 - fVar13) * (param_2 - fVar13));
    fVar17 = (fVar13 - param_2) / fVar19;
    fVar15 = fVar17 * *(float *)(param_3 + 0x44) * 0.5;
    fVar16 = (fVar14 / fVar19) * *(float *)(param_3 + 0x44) * 0.5;
    fVar17 = fVar17 * fVar18;
    fVar14 = (fVar14 / fVar19) * fVar18;
    fVar20 = fVar12 + fVar15;
    fVar21 = fVar16 + fVar13;
    fVar23 = fVar17 + param_1;
    fVar22 = fVar14 + param_2;
    fVar12 = fVar12 - fVar15;
    fVar13 = fVar13 - fVar16;
    fVar17 = param_1 - fVar17;
    fVar14 = param_2 - fVar14;
    uVar9 = CONCAT44(fVar14,fVar17);
    if (param_3[0x5c] == '\x02') {
      FUN_00b6a3e4(*(undefined4 *)(param_3 + 0x68),*(undefined4 *)(param_3 + 0x6c),
                   *(undefined4 *)(param_3 + 0x78),*(undefined4 *)(param_3 + 0x7c),fVar12,fVar13,
                   fVar20,fVar21,param_3);
    }
    fVar15 = *(float *)(param_3 + 0x38);
    *(float *)(param_3 + 0x38) = fVar19 + fVar15;
    uVar10 = CONCAT44(DAT_00b7a4c4,DAT_00b7a4c4);
    uVar11 = uVar10;
    if (*(int **)(param_3 + 0x30) != (int *)0x0) {
      uVar10 = (**(code **)(**(int **)(param_3 + 0x30) + 8))(fVar19 + fVar15,fVar18,0x3f800000);
      uVar11 = CONCAT44(DAT_00b7a4c4,DAT_00b7a4c4);
      if (*(int **)(param_3 + 0x30) != (int *)0x0) {
        uVar11 = (**(code **)(**(int **)(param_3 + 0x30) + 8))
                           (*(undefined4 *)(param_3 + 0x38),fVar18,0xbf800000);
      }
    }
    FUN_00b797d8(fVar12,fVar13,fVar17,fVar14,fVar20,fVar21,fVar23,fVar22,param_3,0);
    if (param_3[0x5c] == '\x01') {
      *(ulonglong *)(param_3 + 0xa4) = CONCAT44(fVar13,fVar12);
      *(undefined8 *)(param_3 + 0xac) = uVar9;
      *(float *)(param_3 + 0xb4) = fVar20;
      *(float *)(param_3 + 0xb8) = fVar21;
      *(float *)(param_3 + 0xbc) = fVar23;
      *(float *)(param_3 + 0xc0) = fVar22;
    }
    *(ulonglong *)(param_3 + 0x60) = CONCAT44(fVar13,fVar12);
    *(undefined8 *)(param_3 + 0x68) = uVar9;
    *(float *)(param_3 + 0x70) = fVar20;
    *(ulonglong *)(param_3 + 0x74) = CONCAT44(fVar23,fVar21);
    *(float *)(param_3 + 0x7c) = fVar22;
    *(ulonglong *)(param_3 + 0x3c) = CONCAT44(param_2,param_1);
    *(ulonglong *)(param_3 + 0x44) =
         CONCAT44(*(undefined4 *)(param_3 + 0x38),*(undefined4 *)(param_3 + 4));
    *(undefined8 *)(param_3 + 0x4c) = uVar10;
    *(undefined8 *)(param_3 + 0x54) = uVar11;
    param_3[0x5c] = 2;
    param_3[0x5d] = *param_3;
    param_3[0x5e] = param_3[1];
  }
  return;
}

