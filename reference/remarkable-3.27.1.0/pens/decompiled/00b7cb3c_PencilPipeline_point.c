
void FUN_00b7cb3c(float param_1,float param_2,undefined1 *param_3)

{
  undefined1 uVar1;
  undefined8 uVar2;
  undefined4 *puVar3;
  float *pfVar4;
  float *pfVar5;
  int *piVar6;
  undefined4 uVar7;
  undefined4 *puVar8;
  undefined8 *puVar9;
  undefined8 *puVar10;
  code *pcVar11;
  float *pfVar12;
  float *pfVar13;
  undefined4 uVar14;
  undefined4 uVar15;
  undefined8 uVar16;
  undefined8 uVar17;
  float extraout_s2;
  float extraout_s2_00;
  float extraout_s3;
  float extraout_s3_00;
  float fVar18;
  float fVar19;
  float fVar20;
  float fVar21;
  float fVar22;
  float fVar23;
  undefined8 unaff_d8;
  float fVar24;
  float fVar25;
  float fVar26;
  float fVar27;
  float fVar28;
  float fVar29;
  undefined8 local_b0;
  undefined4 local_98;
  undefined8 local_80;
  undefined4 local_70;
  undefined4 uStack_6c;
  float local_60 [2];
  undefined8 local_58;
  undefined8 local_50;
  undefined4 uStack_48;
  
  if (param_3[0x6c] != '\0') {
    fVar21 = *(float *)(param_3 + 0x3c);
    if ((fVar21 == param_1) && (*(float *)(param_3 + 0x40) == param_2)) {
      return;
    }
    if (param_3[0x14] != '\0') {
      local_50._4_4_ = (undefined4)unaff_d8;
      uStack_48 = (undefined4)((ulonglong)unaff_d8 >> 0x20);
      fVar18 = *(float *)(param_3 + 0x40);
      fVar27 = *(float *)(param_3 + 0x3c);
      fVar23 = *(float *)(param_3 + 0xc);
      fVar19 = param_1 - fVar27;
      fVar22 = *(float *)(param_3 + 8);
      fVar20 = *(float *)(param_3 + 0x10);
      fVar26 = *(float *)(param_3 + 4) * 0.5;
      fVar25 = SQRT((param_2 - fVar18) * (param_2 - fVar18) + fVar19 * fVar19);
      fVar21 = (fVar18 - param_2) / fVar25;
      fVar24 = ABS(fVar23 * (fVar19 / fVar25) + fVar22 * fVar21) * *(float *)(param_3 + 4);
      if (fVar20 == fVar24 || fVar20 < fVar24 != (NAN(fVar20) || NAN(fVar24))) {
        fVar21 = fVar22 * *(float *)(param_3 + 0x44) * 0.5;
        fVar19 = fVar23 * *(float *)(param_3 + 0x44) * 0.5;
        fVar20 = fVar23 * fVar26;
        fVar22 = fVar22 * fVar26;
      }
      else {
        fVar21 = fVar21 * fVar20 * 0.5;
        fVar19 = (fVar19 / fVar25) * fVar20 * 0.5;
        fVar20 = fVar19;
        fVar22 = fVar21;
      }
      fVar24 = param_1 - fVar22;
      fVar23 = param_2 - fVar20;
      fVar29 = fVar18 - fVar19;
      fVar22 = fVar22 + param_1;
      fVar20 = fVar20 + param_2;
      fVar28 = fVar27 + fVar21;
      fVar18 = fVar18 + fVar19;
      fVar27 = fVar27 - fVar21;
      if (param_3[0x6c] == '\x02') {
        local_60[0] = fVar27;
        local_60[1] = fVar29;
        local_58._0_4_ = fVar24;
        local_58._4_4_ = fVar23;
        FUN_00b6aacc(*(undefined4 *)(param_3 + 0x78),*(undefined4 *)(param_3 + 0x7c),
                     *(undefined4 *)(param_3 + 0x88),*(undefined4 *)(param_3 + 0x8c),fVar27,fVar29,
                     fVar28,fVar18,param_3);
      }
      piVar6 = *(int **)(param_3 + 0x30);
      fVar25 = fVar25 + *(float *)(param_3 + 0x38);
      *(float *)(param_3 + 0x38) = fVar25;
      if (piVar6 == (int *)0x0) {
        uVar17 = 0;
        local_98 = 0;
      }
      else if (*(code **)(*piVar6 + 8) == (code *)&UNK_00b6cfd8) {
        uVar17 = CONCAT44(fVar26 * (float)piVar6[3],fVar25 * (float)piVar6[2]);
      }
      else {
        uVar17 = (**(code **)(*piVar6 + 8))(fVar25,fVar26,0x3f800000);
        if ((*(int **)(param_3 + 0x30) != (int *)0x0) &&
           (pcVar11 = *(code **)(**(int **)(param_3 + 0x30) + 8), pcVar11 != (code *)&UNK_00b6cfd8))
        {
          (*pcVar11)(*(undefined4 *)(param_3 + 0x38),fVar26,0xbf800000);
        }
      }
      FUN_00b7be24(fVar27,fVar29,fVar24,fVar23,fVar28,fVar18,fVar22,fVar20,param_3,0);
      if (param_3[0x6c] == '\x01') {
        *(float *)(param_3 + 0xc4) = fVar27;
        *(float *)(param_3 + 200) = fVar29;
        *(float *)(param_3 + 0xcc) = fVar24;
        *(float *)(param_3 + 0xd0) = fVar23;
        *(float *)(param_3 + 0xd4) = fVar28;
        *(float *)(param_3 + 0xd8) = fVar18;
        *(float *)(param_3 + 0xdc) = fVar22;
        *(float *)(param_3 + 0xe0) = fVar20;
      }
      *(float *)(param_3 + 0x70) = fVar27;
      *(float *)(param_3 + 0x74) = fVar29;
      *(float *)(param_3 + 0x78) = fVar24;
      *(float *)(param_3 + 0x7c) = fVar23;
      *(float *)(param_3 + 0x80) = fVar28;
      *(float *)(param_3 + 0x84) = fVar18;
      *(float *)(param_3 + 0x88) = fVar22;
      *(float *)(param_3 + 0x8c) = fVar20;
      local_80._0_4_ = local_98;
      goto LAB_00b751ec;
    }
    fVar19 = param_1 - fVar21;
    fVar18 = *(float *)(param_3 + 0x40);
    fVar24 = *(float *)(param_3 + 4) * 0.5;
    fVar25 = SQRT(fVar19 * fVar19 + (param_2 - fVar18) * (param_2 - fVar18));
    fVar23 = (fVar18 - param_2) / fVar25;
    fVar20 = fVar23 * *(float *)(param_3 + 0x44) * 0.5;
    fVar22 = (fVar19 / fVar25) * *(float *)(param_3 + 0x44) * 0.5;
    fVar23 = fVar23 * fVar24;
    fVar19 = (fVar19 / fVar25) * fVar24;
    fVar26 = fVar21 + fVar20;
    fVar27 = fVar22 + fVar18;
    fVar29 = fVar23 + param_1;
    fVar28 = fVar19 + param_2;
    fVar21 = fVar21 - fVar20;
    fVar18 = fVar18 - fVar22;
    fVar23 = param_1 - fVar23;
    fVar19 = param_2 - fVar19;
    local_b0 = CONCAT44(fVar29,fVar27);
    uVar16 = CONCAT44(fVar19,fVar23);
    if (param_3[0x6c] == '\x02') {
      FUN_00b6aacc(*(undefined4 *)(param_3 + 0x78),*(undefined4 *)(param_3 + 0x7c),
                   *(undefined4 *)(param_3 + 0x88),*(undefined4 *)(param_3 + 0x8c),fVar21,fVar18,
                   fVar26,fVar27,param_3);
    }
    piVar6 = *(int **)(param_3 + 0x30);
    fVar25 = fVar25 + *(float *)(param_3 + 0x38);
    *(float *)(param_3 + 0x38) = fVar25;
    if (piVar6 == (int *)0x0) {
      uVar17 = 0;
      local_80 = 0;
LAB_00b7ce10:
      uVar2 = 0;
    }
    else if (*(code **)(*piVar6 + 8) == (code *)&UNK_00b6cfd8) {
      uVar17 = CONCAT44(fVar24 * (float)piVar6[3],fVar25 * (float)piVar6[2]);
LAB_00b7cca0:
      uVar2 = CONCAT44(-(fVar24 * (float)piVar6[3]),fVar25 * (float)piVar6[2]);
    }
    else {
      uVar17 = (**(code **)(*piVar6 + 8))(fVar25,fVar24,0x3f800000);
      piVar6 = *(int **)(param_3 + 0x30);
      fVar25 = *(float *)(param_3 + 0x38);
      if (piVar6 == (int *)0x0) goto LAB_00b7ce10;
      if (*(code **)(*piVar6 + 8) == (code *)&UNK_00b6cfd8) goto LAB_00b7cca0;
      local_58 = (**(code **)(*piVar6 + 8))(fVar25,fVar24,0xbf800000);
      uVar2 = local_58;
    }
    FUN_00b7be24(fVar21,fVar18,fVar23,fVar19,fVar26,fVar27,fVar29,fVar28,param_3,0,
                 (undefined4)local_80,local_80._4_4_,uVar17,(undefined4)local_80,local_80._4_4_,
                 uVar2,local_70,uStack_6c);
    if (param_3[0x6c] == '\x01') {
      *(ulonglong *)(param_3 + 0xc4) = CONCAT44(fVar18,fVar21);
      *(undefined8 *)(param_3 + 0xcc) = uVar16;
      *(float *)(param_3 + 0xd4) = fVar26;
      *(float *)(param_3 + 0xd8) = fVar27;
      *(float *)(param_3 + 0xdc) = fVar29;
      *(float *)(param_3 + 0xe0) = fVar28;
    }
    *(ulonglong *)(param_3 + 0x70) = CONCAT44(fVar18,fVar21);
    *(undefined8 *)(param_3 + 0x78) = uVar16;
    *(float *)(param_3 + 0x80) = fVar26;
    *(undefined8 *)(param_3 + 0x84) = local_b0;
    *(float *)(param_3 + 0x8c) = fVar28;
LAB_00b751ec:
    local_60[0] = param_1;
    local_60[1] = param_2;
    local_50 = uVar17;
    uStack_48 = (undefined4)local_80;
    pfVar4 = local_60;
    pfVar5 = (float *)(param_3 + 0x3c);
    do {
      pfVar13 = pfVar5;
      pfVar12 = pfVar4;
      fVar21 = pfVar12[1];
      fVar25 = pfVar12[2];
      fVar18 = pfVar12[3];
      *pfVar13 = *pfVar12;
      pfVar13[1] = fVar21;
      pfVar13[2] = fVar25;
      pfVar13[3] = fVar18;
      pfVar4 = pfVar12 + 4;
      pfVar5 = pfVar13 + 4;
    } while (pfVar12 + 4 != (float *)&stack0xffffffd0);
    uVar1 = *(undefined1 *)((int)pfVar12 + 0x12);
    *(undefined2 *)(pfVar13 + 4) = *(undefined2 *)(pfVar12 + 4);
    *(undefined1 *)((int)pfVar13 + 0x12) = uVar1;
    return;
  }
  if (param_3[0x6c] == '\x02') {
    if (param_3[0xe4] == '\0') {
      FUN_00b6a71c(*(undefined4 *)(param_3 + 0xc4),*(undefined4 *)(param_3 + 200),
                   *(undefined4 *)(param_3 + 0xcc),*(undefined4 *)(param_3 + 0xd0),
                   *(undefined4 *)(param_3 + 0xd4),*(undefined4 *)(param_3 + 0xd8),
                   *(undefined4 *)(param_3 + 0xdc),*(undefined4 *)(param_3 + 0xe0),param_3,0);
      param_3[0xe4] = 1;
      if ((param_3[0xe5] == '\0') && (param_3[0x6c] == '\x02')) {
LAB_00b7c6a0:
        FUN_00b6a71c(*(undefined4 *)(param_3 + 0x70),*(undefined4 *)(param_3 + 0x74),
                     *(undefined4 *)(param_3 + 0x78),*(undefined4 *)(param_3 + 0x7c),
                     *(undefined4 *)(param_3 + 0x80),*(undefined4 *)(param_3 + 0x84),
                     *(undefined4 *)(param_3 + 0x88),*(undefined4 *)(param_3 + 0x8c),param_3,1);
        param_3[0xe5] = 1;
      }
    }
    else if (param_3[0xe5] == '\0') goto LAB_00b7c6a0;
  }
  uVar16 = CONCAT44(DAT_00b7c7bc,DAT_00b7c7bc);
  piVar6 = *(int **)(param_3 + 0x30);
  fVar20 = *(float *)(param_3 + 0x38);
  fVar22 = *(float *)(param_3 + 4);
  fVar21 = DAT_00b7c7bc;
  fVar25 = DAT_00b7c7bc;
  fVar18 = DAT_00b7c7bc;
  fVar19 = DAT_00b7c7bc;
  uVar17 = uVar16;
  if (piVar6 == (int *)0x0) goto LAB_00b7c558;
  fVar23 = fVar22 * 0.5;
  if (*(code **)(*piVar6 + 8) == (code *)&UNK_00b6cfd8) {
    fVar19 = fVar23 * (float)piVar6[3];
    uVar17 = CONCAT44(fVar19,fVar20 * (float)piVar6[2]);
    fVar25 = (float)piVar6[1];
  }
  else {
    uVar17 = (**(code **)(*piVar6 + 8))(fVar20,fVar23,0x3f800000);
    uVar16 = CONCAT44(DAT_00b7c7bc,DAT_00b7c7bc);
    piVar6 = *(int **)(param_3 + 0x30);
    fVar22 = *(float *)(param_3 + 4);
    fVar20 = *(float *)(param_3 + 0x38);
    fVar23 = fVar22 * 0.5;
    fVar21 = DAT_00b7c7bc;
    fVar25 = extraout_s2;
    fVar18 = DAT_00b7c7bc;
    fVar19 = extraout_s3;
    if (piVar6 == (int *)0x0) goto LAB_00b7c558;
    if (*(code **)(*piVar6 + 8) != (code *)&UNK_00b6cfd8) {
      uVar16 = (**(code **)(*piVar6 + 8))(fVar20,fVar23,0xbf800000);
      fVar22 = *(float *)(param_3 + 4);
      fVar20 = *(float *)(param_3 + 0x38);
      fVar21 = extraout_s2_00;
      fVar25 = extraout_s2;
      fVar18 = extraout_s3_00;
      fVar19 = extraout_s3;
      goto LAB_00b7c558;
    }
  }
  uVar16 = CONCAT44(-(fVar23 * (float)piVar6[3]),fVar20 * (float)piVar6[2]);
  fVar21 = (float)piVar6[1];
  fVar18 = --(fVar23 * (float)piVar6[3]);
LAB_00b7c558:
  *(ulonglong *)(param_3 + 0x3c) = CONCAT44(param_2,param_1);
  *(ulonglong *)(param_3 + 0x44) = CONCAT44(fVar20,fVar22);
  *(undefined8 *)(param_3 + 0x4c) = uVar17;
  *(ulonglong *)(param_3 + 0x54) = CONCAT44(fVar19,fVar25);
  *(undefined8 *)(param_3 + 0x5c) = uVar16;
  *(float *)(param_3 + 0x6c) = fVar21;
  *(float *)(param_3 + 0x70) = fVar18;
  param_3[0x6d] = *param_3;
  param_3[0x6e] = param_3[1];
  param_3[0x6c] = 1;
  puVar3 = (undefined4 *)(param_3 + 0x90);
  puVar10 = (undefined8 *)(param_3 + 0x3c);
  do {
    puVar9 = puVar10;
    puVar8 = puVar3;
    puVar10 = puVar9 + 2;
    uVar15 = *(undefined4 *)((int)puVar9 + 4);
    uVar14 = *(undefined4 *)(puVar9 + 1);
    uVar7 = *(undefined4 *)((int)puVar9 + 0xc);
    *puVar8 = *(undefined4 *)puVar9;
    puVar8[1] = uVar15;
    puVar8[2] = uVar14;
    puVar8[3] = uVar7;
    puVar3 = puVar8 + 4;
  } while (puVar10 != (undefined8 *)(param_3 + 0x6c));
  uVar1 = *(undefined1 *)((int)puVar9 + 0x12);
  *(undefined2 *)(puVar8 + 4) = *(undefined2 *)puVar10;
  *(undefined1 *)((int)puVar8 + 0x12) = uVar1;
  return;
}

