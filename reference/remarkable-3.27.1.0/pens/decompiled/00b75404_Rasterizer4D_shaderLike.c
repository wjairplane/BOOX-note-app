
void FUN_00b75404(float param_1,float param_2,float param_3,float param_4,float param_5,
                 float param_6,float param_7,float param_8,int *param_9,float param_10,
                 float param_11,float param_12)

{
  byte bVar1;
  byte bVar2;
  float fVar3;
  int iVar4;
  uint uVar5;
  int iVar6;
  int iVar7;
  uint uVar8;
  undefined2 *puVar9;
  int iVar10;
  bool bVar11;
  uint in_fpscr;
  uint uVar12;
  uint uVar13;
  float fVar14;
  float fVar15;
  float extraout_s5;
  float extraout_s5_00;
  float extraout_s5_01;
  float extraout_s6;
  float extraout_s6_00;
  float extraout_s6_01;
  float in_s8;
  float in_s9;
  float in_s10;
  float in_s11;
  float fVar16;
  int iVar17;
  int iVar18;
  float fVar19;
  float fVar20;
  float fVar21;
  uint uVar22;
  float fVar23;
  float fVar24;
  float fVar25;
  float fVar26;
  uint uVar27;
  float fVar28;
  float fVar29;
  float fVar30;
  uint uVar31;
  uint uVar32;
  float fVar33;
  float fVar34;
  float fVar35;
  float fVar36;
  float fVar37;
  float fVar38;
  float fVar39;
  float fVar40;
  float fVar41;
  float fVar42;
  float fVar43;
  float fVar44;
  float fStack00000004;
  float fStack00000008;
  float fStack0000000c;
  float in_stack_00000010;
  float in_stack_00000014;
  float in_stack_00000018;
  float fStack_e8;
  float fStack_e4;
  float fStack_dc;
  float fStack_d8;
  float fStack_d4;
  float fStack_d0;
  float fStack_cc;
  float fStack_c8;
  float fStack_c0;
  float fStack_b8;
  float fStack_b4;
  float fStack_b0;
  float fStack_ac;
  float fStack_a8;
  float fStack_a4;
  float fStack_a0;
  float fStack_9c;
  float fStack_98;
  float fStack_94;
  float fStack_90;
  float fStack_8c;
  float fStack_88;
  float fStack_84;
  float fStack_80;
  float fStack_7c;
  float fStack_78;
  float fStack_74;
  float fStack_70;
  float fStack_6c;
  float fStack_68;
  float fStack_64;
  
  uVar27 = in_fpscr & 0xfffffff | (uint)(in_stack_00000010 < param_11) << 0x1f;
  fStack00000004 = param_10;
  fStack00000008 = param_11;
  fStack0000000c = param_12;
  fStack_b0 = in_s8;
  fStack_ac = in_s9;
  fStack_a8 = in_s10;
  fStack_a4 = in_s11;
  fStack_a0 = param_5;
  fStack_9c = param_6;
  fStack_98 = param_7;
  fStack_94 = param_8;
  fStack_90 = param_1;
  fStack_8c = param_2;
  fStack_88 = param_3;
  fStack_84 = param_4;
  if (SUB41(uVar27 >> 0x1f,0)) {
    FUN_00b753cc(&fStack_90,&fStack_a0);
    uVar27 = uVar27 & 0xfffffff | (uint)(in_stack_00000018 < in_stack_00000010) << 0x1f;
    bVar1 = (byte)(uVar27 >> 0x18);
    fStack_b4 = param_10;
    fStack_c0 = param_11;
    param_10 = param_12;
  }
  else {
    uVar27 = in_fpscr & 0xfffffff | (uint)(in_stack_00000018 < param_11) << 0x1f;
    bVar1 = (byte)(uVar27 >> 0x18);
    fStack_b4 = param_12;
    fStack_c0 = in_stack_00000010;
    in_stack_00000010 = param_11;
  }
  if ((bool)(bVar1 >> 7)) {
    FUN_00b753cc(&fStack_90,&fStack_b0);
    uVar27 = uVar27 & 0xfffffff | (uint)(in_stack_00000010 < fStack_c0) << 0x1f;
    bVar1 = (byte)(uVar27 >> 0x18);
    fVar38 = in_stack_00000018;
    fVar14 = param_10;
  }
  else {
    uVar27 = uVar27 & 0xfffffff | (uint)(in_stack_00000018 < fStack_c0) << 0x1f;
    bVar1 = (byte)(uVar27 >> 0x18);
    fVar38 = in_stack_00000010;
    fVar14 = in_stack_00000014;
    in_stack_00000014 = param_10;
    in_stack_00000010 = in_stack_00000018;
  }
  fVar33 = in_stack_00000010;
  fStack_b8 = fVar14;
  if ((bool)(bVar1 >> 7)) {
    FUN_00b753cc(&fStack_b0,&fStack_a0);
    fVar33 = fStack_c0;
    fStack_c0 = in_stack_00000010;
    fStack_b8 = fStack_b4;
    fStack_b4 = fVar14;
  }
  fVar14 = floorf(fVar38);
  fVar23 = 0.5;
  uVar27 = uVar27 & 0xfffffff | (uint)(fVar38 - fVar14 < 0.5) << 0x1f;
  if (!SUB41(uVar27 >> 0x1f,0)) {
    fVar23 = 1.5;
  }
  fVar14 = fVar14 + fVar23;
  fVar23 = floorf(fStack_c0);
  uVar27 = uVar27 & 0xfffffff | (uint)(fStack_c0 - fVar23 < 0.5) << 0x1f;
  if (SUB41(uVar27 >> 0x1f,0)) {
    fVar23 = fVar23 - 0.5;
  }
  else {
    fVar23 = fVar23 + 0.5;
  }
  fVar15 = floorf(fVar33);
  fVar34 = fStack_84;
  fVar35 = fStack_88;
  fVar36 = fStack_8c;
  fVar37 = fStack_90;
  if (fVar33 - fVar15 < 0.5) {
    fVar15 = fVar15 - 0.5;
  }
  else {
    fVar15 = fVar15 + 0.5;
  }
  uVar12 = uVar27 & 0xfffffff | (uint)(fVar14 == fVar23) << 0x1e | (uint)(fVar23 <= fVar14) << 0x1d;
  bVar1 = (byte)(uVar12 >> 0x18);
  fVar20 = extraout_s5;
  fVar24 = extraout_s6;
  if (!(bool)(bVar1 >> 5 & 1) || (bool)(bVar1 >> 6)) {
    fStack_c8 = fStack_c0 - fVar38;
    fVar24 = fVar33 - fVar38;
    fVar20 = (fStack_b4 - in_stack_00000014) / fStack_c8;
    fStack_d8 = (fStack_b8 - in_stack_00000014) / fVar24;
    if (fStack_c8 == 0.0) {
      fStack_c8 = DAT_00b7601c;
      fStack_cc = DAT_00b7601c;
      fStack_d0 = DAT_00b7601c;
      fStack_d4 = DAT_00b7601c;
    }
    else {
      fStack_d4 = (fStack_a0 - fStack_90) / fStack_c8;
      fStack_d0 = (fStack_9c - fStack_8c) / fStack_c8;
      fStack_cc = (fStack_98 - fStack_88) / fStack_c8;
      fStack_c8 = (fStack_94 - fStack_84) / fStack_c8;
    }
    bVar11 = fVar24 == 0.0;
    fStack_80 = fStack_d4;
    fStack_7c = fStack_d0;
    fStack_64 = DAT_00b758e8;
    fStack_70 = extraout_s6;
    if (!bVar11) {
      fStack_70 = (fStack_b0 - fStack_90) / fVar24;
      fStack_64 = fStack_98 - fStack_88;
    }
    fStack_78 = fStack_cc;
    fStack_68 = fStack_9c - fStack_8c;
    fStack_6c = fStack_a0 - fStack_90;
    if (bVar11) {
      fStack_70 = fStack_64;
      fStack_68 = fStack_64;
      fStack_6c = fStack_64;
    }
    fStack_74 = fStack_c8;
    if (!bVar11) {
      fStack_6c = (fStack_ac - fStack_8c) / fVar24;
      fStack_68 = (fStack_a8 - fStack_88) / fVar24;
      fStack_64 = (fStack_a4 - fStack_84) / fVar24;
    }
    uVar27 = uVar27 & 0xfffffff | (uint)(fVar20 < fStack_d8) << 0x1f |
             (uint)(fVar20 == fStack_d8) << 0x1e;
    uVar12 = uVar27 | (uint)(NAN(fVar20) || NAN(fStack_d8)) << 0x1c;
    bVar1 = (byte)(uVar27 >> 0x18);
    fStack_dc = fVar20;
    if (!(bool)(bVar1 >> 6 & 1) && bVar1 >> 7 == ((byte)(uVar12 >> 0x1c) & 1)) {
      FUN_00b753cc(&fStack_80,&fStack_70);
      fStack_dc = fStack_d8;
      fStack_d8 = fVar20;
    }
    fVar30 = fStack_74;
    fVar29 = fStack_78;
    fVar44 = fStack_7c;
    fVar3 = fStack_80;
    fVar25 = fVar23 - fVar38;
    fVar20 = in_stack_00000014 + fVar25 * fStack_dc;
    fVar24 = fVar37 + fVar25 * fStack_80;
    fVar26 = (in_stack_00000014 + fVar25 * fStack_d8) - fVar20;
    uVar12 = uVar12 & 0xfffffff | (uint)(fVar26 == 0.0) << 0x1e;
    bVar11 = SUB41(uVar12 >> 0x1e,0);
    if (bVar11) {
      fStack_e8 = DAT_00b758e8;
      fVar26 = DAT_00b758e8;
      fVar21 = fStack_74;
      fStack_e4 = DAT_00b758e8;
      fVar41 = DAT_00b758e8;
    }
    else {
      fStack_e8 = ((fVar37 + fVar25 * fStack_70) - fVar24) / fVar26;
      fVar41 = ((fVar34 + fVar25 * fStack_64) - (fVar34 + fVar25 * fStack_74)) / fVar26;
      fVar21 = ((fVar36 + fVar25 * fStack_6c) - (fVar36 + fVar25 * fStack_7c)) / fVar26;
      fVar26 = ((fVar35 + fVar25 * fStack_68) - (fVar35 + fVar25 * fStack_78)) / fVar26;
    }
    fVar25 = fVar14 - fVar38;
    if (!bVar11) {
      fStack_e4 = fVar21;
    }
    fVar43 = in_stack_00000014 + fVar25 * fStack_dc;
    fVar21 = in_stack_00000014 + fVar25 * fStack_d8;
    fVar37 = fVar37 + fVar25 * fStack_80;
    fVar36 = fVar36 + fVar25 * fStack_7c;
    fVar35 = fVar35 + fVar25 * fStack_78;
    fVar34 = fVar34 + fVar25 * fStack_74;
    do {
      uVar27 = (uint)(fVar43 + 0.5);
      if ((int)uVar27 <= (int)(fVar21 - 0.5)) {
        uVar22 = (uint)fVar14;
        fVar25 = (float)VectorSignedToFloat(uVar27,(byte)(uVar12 >> 0x15) & 3);
        iVar6 = (int)(fVar21 - 0.5) - uVar27;
        fVar25 = (fVar25 + 0.5) - fVar43;
        fVar39 = fVar37 + fVar25 * fStack_e8;
        fVar42 = fVar35 + fVar25 * fVar26;
        fVar40 = fVar36 + fVar25 * fStack_e4;
        fVar25 = fVar34 + fVar25 * fVar41;
        if (param_9[2] == 0x20) {
          iVar10 = *param_9;
          iVar4 = uVar27 + 1;
          bVar1 = (&DAT_011dd648)[uVar22 & 0xff];
          iVar7 = param_9[1];
          do {
            iVar17 = FUN_00b6ea90(fVar39,fVar40);
            fVar24 = (float)VectorSignedToFloat(iVar17 * 3 +
                                                (uint)(byte)(&DAT_011dd648)
                                                            [(uint)bVar1 + (uVar27 & 0xff)] >> 2,
                                                (byte)(uVar12 >> 0x15) & 3);
            fVar28 = ABS(fVar40 / fVar25);
            uVar13 = uVar12 & 0xfffffff | (uint)(fVar28 < 0.5) << 0x1f;
            fVar20 = fVar42;
            if (!SUB41(uVar13 >> 0x1f,0)) {
              uVar13 = uVar12 & 0xfffffff | (uint)(fVar28 < 1.0) << 0x1f |
                       (uint)(fVar28 == 1.0) << 0x1e;
              bVar2 = (byte)(uVar13 >> 0x18);
              if ((bool)(bVar2 >> 6 & 1) || (bool)(bVar2 >> 7) != NAN(fVar28)) {
                fVar20 = (fVar28 - 0.5) + (fVar28 - 0.5);
                fVar20 = (1.0 - (3.0 - (fVar20 + fVar20)) * fVar20 * fVar20) * fVar42;
              }
              else {
                fVar20 = fVar42 * DAT_00b7601c;
              }
            }
            uVar12 = uVar13 & 0xfffffff | (uint)(fVar24 == fVar20) << 0x1e |
                     (uint)(fVar20 <= fVar24) << 0x1d;
            fVar42 = fVar42 + fVar26;
            fVar39 = fVar39 + fStack_e8;
            bVar2 = (byte)(uVar12 >> 0x18);
            fVar25 = fVar25 + fVar41;
            fVar40 = fVar40 + fStack_e4;
            if (!(bool)(bVar2 >> 5 & 1) || (bool)(bVar2 >> 6)) {
              *(int *)(iVar7 * uVar22 + iVar10 + uVar27 * 4) = param_9[3];
            }
            uVar27 = uVar27 + 1;
            fVar20 = extraout_s5_01;
            fVar24 = extraout_s6_01;
          } while (iVar4 + iVar6 != uVar27);
        }
        else if (param_9[2] == 0x10) {
          iVar7 = uVar27 + 1;
          bVar1 = (&DAT_011dd648)[uVar22 & 0xff];
          puVar9 = (undefined2 *)(*param_9 + param_9[1] * uVar22 + uVar27 * 2);
          do {
            iVar4 = FUN_00b6ea90(fVar39,fVar40);
            fVar24 = (float)VectorSignedToFloat(iVar4 * 3 +
                                                (uint)(byte)(&DAT_011dd648)
                                                            [(uint)bVar1 + (uVar27 & 0xff)] >> 2,
                                                (byte)(uVar12 >> 0x15) & 3);
            fVar28 = ABS(fVar40 / fVar25);
            uVar22 = uVar12 & 0xfffffff | (uint)(fVar28 < 0.5) << 0x1f;
            fVar20 = fVar42;
            if (!SUB41(uVar22 >> 0x1f,0)) {
              uVar22 = uVar12 & 0xfffffff | (uint)(fVar28 < 1.0) << 0x1f |
                       (uint)(fVar28 == 1.0) << 0x1e;
              bVar2 = (byte)(uVar22 >> 0x18);
              if ((bool)(bVar2 >> 6 & 1) || (bool)(bVar2 >> 7) != NAN(fVar28)) {
                fVar20 = (fVar28 - 0.5) + (fVar28 - 0.5);
                fVar20 = (1.0 - (3.0 - (fVar20 + fVar20)) * fVar20 * fVar20) * fVar42;
              }
              else {
                fVar20 = fVar42 * DAT_00b758e8;
              }
            }
            uVar12 = uVar22 & 0xfffffff | (uint)(fVar24 == fVar20) << 0x1e |
                     (uint)(fVar20 <= fVar24) << 0x1d;
            uVar27 = uVar27 + 1;
            fVar42 = fVar42 + fVar26;
            fVar39 = fVar39 + fStack_e8;
            bVar2 = (byte)(uVar12 >> 0x18);
            fVar25 = fVar25 + fVar41;
            fVar40 = fVar40 + fStack_e4;
            if (!(bool)(bVar2 >> 5 & 1) || (bool)(bVar2 >> 6)) {
              *puVar9 = (short)param_9[4];
            }
            puVar9 = puVar9 + 1;
            fVar20 = extraout_s5_00;
            fVar24 = extraout_s6_00;
          } while (iVar7 + iVar6 != uVar27);
        }
      }
      fVar14 = fVar14 + 1.0;
      fVar43 = fVar43 + fStack_dc;
      fVar21 = fVar21 + fStack_d8;
      fVar37 = fVar37 + fVar3;
      fVar36 = fVar36 + fVar44;
      fVar35 = fVar35 + fVar29;
      fVar34 = fVar34 + fVar30;
      uVar27 = uVar12 & 0xfffffff | (uint)(fVar23 < fVar14) << 0x1f;
      uVar12 = uVar27 | (uint)(NAN(fVar23) || NAN(fVar14)) << 0x1c;
    } while ((byte)(uVar27 >> 0x1f) == ((byte)(uVar12 >> 0x1c) & 1));
  }
  if (fVar14 <= fVar15) {
    fStack_c0 = fVar33 - fStack_c0;
    fVar38 = fVar33 - fVar38;
    bVar11 = fStack_c0 == 0.0;
    fStack_74 = fStack_ac - fStack_9c;
    fVar23 = (fStack_b8 - fStack_b4) / fStack_c0;
    fStack_78 = fStack_b0 - fStack_a0;
    if (bVar11) {
      fStack_78 = DAT_00b758e8;
      fStack_74 = DAT_00b758e8;
    }
    fStack_80 = fVar20;
    fStack_7c = fVar24;
    if (bVar11) {
      fStack_80 = fStack_74;
      fStack_7c = fStack_74;
    }
    fVar37 = (fStack_b8 - in_stack_00000014) / fVar38;
    if (!bVar11) {
      fStack_80 = fStack_78 / fStack_c0;
      fStack_7c = fStack_74 / fStack_c0;
      fStack_78 = (fStack_a8 - fStack_98) / fStack_c0;
    }
    if (!bVar11) {
      fStack_74 = (fStack_a4 - fStack_94) / fStack_c0;
    }
    uVar27 = uVar12 & 0xfffffff | (uint)(fVar23 < fVar37) << 0x1f;
    fStack_64 = DAT_00b758e8;
    fStack_6c = DAT_00b758e8;
    fStack_70 = DAT_00b758e8;
    fStack_68 = DAT_00b758e8;
    if (fVar38 != 0.0) {
      fStack_70 = (fStack_b0 - fStack_90) / fVar38;
      fStack_6c = (fStack_ac - fStack_8c) / fVar38;
      fStack_68 = (fStack_a8 - fStack_88) / fVar38;
      fStack_64 = (fStack_a4 - fStack_84) / fVar38;
    }
    fVar38 = fVar23;
    if (SUB41(uVar27 >> 0x1f,0)) {
      FUN_00b753cc(&fStack_80,&fStack_70);
      fVar38 = fVar37;
      fVar37 = fVar23;
    }
    fVar3 = fStack_74;
    fVar24 = fStack_78;
    fVar20 = fStack_7c;
    fVar34 = fStack_80;
    fVar33 = fVar33 - fVar14;
    fVar29 = fStack_b8 - fVar33 * fVar37;
    fStack_b8 = fStack_b8 - fVar33 * fVar38;
    fVar26 = fStack_b0 - fVar33 * fStack_80;
    fVar25 = fStack_ac - fVar33 * fStack_7c;
    fVar21 = fStack_a8 - fVar33 * fStack_78;
    fVar30 = fVar29 - fStack_b8;
    fVar41 = fStack_a4 - fVar33 * fStack_74;
    uVar27 = uVar27 & 0xfffffff | (uint)(fVar30 == 0.0) << 0x1e;
    fVar35 = DAT_00b758e8;
    fVar36 = DAT_00b758e8;
    fVar23 = DAT_00b758e8;
    fVar44 = DAT_00b758e8;
    if (!SUB41(uVar27 >> 0x1e,0)) {
      fVar35 = ((fStack_a8 - fVar33 * fStack_68) - fVar21) / fVar30;
      fVar36 = ((fStack_b0 - fVar33 * fStack_70) - fVar26) / fVar30;
      fVar23 = ((fStack_ac - fVar33 * fStack_6c) - fVar25) / fVar30;
      fVar44 = ((fStack_a4 - fVar33 * fStack_64) - fVar41) / fVar30;
    }
    do {
      fVar30 = DAT_00b758e8;
      fVar33 = DAT_00b758e4;
      uVar12 = (uint)(fStack_b8 + 0.5);
      if ((int)uVar12 <= (int)(fVar29 - 0.5)) {
        uVar22 = (uint)fVar14;
        fVar43 = (float)VectorSignedToFloat(uVar12,(byte)(uVar27 >> 0x15) & 3);
        iVar6 = (int)(fVar29 - 0.5) - uVar12;
        fVar43 = (fVar43 + 0.5) - fStack_b8;
        fVar40 = fVar26 + fVar43 * fVar36;
        fVar39 = fVar25 + fVar43 * fVar23;
        fVar42 = fVar21 + fVar43 * fVar35;
        fVar43 = fVar41 + fVar43 * fVar44;
        if (param_9[2] == 0x20) {
          iVar4 = *param_9;
          bVar1 = (&DAT_011dd648)[uVar22 & 0xff];
          iVar7 = param_9[1];
          iVar10 = uVar12 + 1;
          do {
            uVar27 = uVar27 & 0xfffffff;
            uVar31 = (uint)fVar40;
            uVar13 = uVar27 | (uint)(fVar39 < 0.0) << 0x1f;
            uVar32 = (uint)fVar39;
            if (fVar40 < 0.0) {
              uVar5 = uVar31 - 1;
            }
            else {
              uVar5 = uVar31;
              uVar31 = uVar31 + 1;
            }
            if (SUB41(uVar13 >> 0x1f,0)) {
              uVar8 = uVar32;
              uVar32 = uVar32 - 1;
            }
            else {
              uVar8 = uVar32 + 1;
            }
            fVar16 = (float)VectorSignedToFloat(uVar5,(byte)(uVar13 >> 0x15) & 3);
            fVar28 = (float)VectorSignedToFloat(uVar32,(byte)(uVar13 >> 0x15) & 3);
            fVar28 = (fVar39 - fVar28) * fVar33;
            iVar17 = (int)((fVar40 - fVar16) * fVar33);
            iVar18 = (int)fVar28;
            fVar16 = ABS(fVar39 / fVar43);
            uVar13 = uVar27 | (uint)(fVar16 < 0.5) << 0x1f;
            bVar11 = SUB41(uVar13 >> 0x1f,0);
            if (bVar11) {
              fVar28 = fVar42;
            }
            fVar19 = (float)VectorSignedToFloat(((int)((0xff - iVar18) *
                                                       ((0xff - iVar17) *
                                                        (uint)(byte)(&DAT_011dd610)
                                                                    [(uVar5 & 0xff) +
                                                                     (uint)(byte)(&DAT_011dd648)
                                                                                 [uVar32 & 0xff] +
                                                                     0x38] +
                                                       iVar17 * (uint)(byte)(&DAT_011dd610)
                                                                            [(uVar31 & 0xff) +
                                                                             (uint)(byte)(&
                                                  DAT_011dd648)[uVar32 & 0xff] + 0x38]) +
                                                  iVar18 * ((0xff - iVar17) *
                                                            (uint)(byte)(&DAT_011dd648)
                                                                        [(uVar5 & 0xff) +
                                                                         (uint)(byte)(&DAT_011dd648)
                                                                                     [uVar8 & 0xff]]
                                                           + iVar17 * (uint)(byte)(&DAT_011dd648)
                                                                                  [(uint)(byte)(&
                                                  DAT_011dd648)[uVar8 & 0xff] + (uVar31 & 0xff)]))
                                                >> 0x10) * 3 +
                                                (uint)(byte)(&DAT_011dd648)
                                                            [(uint)bVar1 + (uVar12 & 0xff)] >> 2,
                                                (byte)(uVar13 >> 0x15) & 3);
            if (!bVar11) {
              uVar13 = uVar27 | (uint)(fVar16 < 1.0) << 0x1f | (uint)(fVar16 == 1.0) << 0x1e;
              bVar2 = (byte)(uVar13 >> 0x18);
              if ((bool)(bVar2 >> 6 & 1) || (bool)(bVar2 >> 7) != NAN(fVar16)) {
                fVar28 = (fVar16 - 0.5) + (fVar16 - 0.5);
                fVar28 = (1.0 - (3.0 - (fVar28 + fVar28)) * fVar28 * fVar28) * fVar42;
              }
              else {
                fVar28 = fVar42 * fVar30;
              }
            }
            uVar27 = uVar13 & 0xfffffff | (uint)(fVar19 == fVar28) << 0x1e |
                     (uint)(fVar28 <= fVar19) << 0x1d;
            fVar40 = fVar40 + fVar36;
            fVar39 = fVar39 + fVar23;
            fVar42 = fVar42 + fVar35;
            bVar2 = (byte)(uVar27 >> 0x18);
            fVar43 = fVar43 + fVar44;
            if (!(bool)(bVar2 >> 5 & 1) || (bool)(bVar2 >> 6)) {
              *(int *)(iVar7 * uVar22 + iVar4 + uVar12 * 4) = param_9[3];
            }
            uVar12 = uVar12 + 1;
          } while (uVar12 != iVar10 + iVar6);
        }
        else if (param_9[2] == 0x10) {
          iVar7 = uVar12 + 1;
          bVar1 = (&DAT_011dd648)[uVar22 & 0xff];
          puVar9 = (undefined2 *)(*param_9 + param_9[1] * uVar22 + uVar12 * 2);
          do {
            iVar4 = FUN_00b6ea90(fVar40,fVar39);
            fVar30 = (float)VectorSignedToFloat(iVar4 * 3 +
                                                (uint)(byte)(&DAT_011dd648)
                                                            [(uint)bVar1 + (uVar12 & 0xff)] >> 2,
                                                (byte)(uVar27 >> 0x15) & 3);
            fVar28 = ABS(fVar39 / fVar43);
            uVar22 = uVar27 & 0xfffffff | (uint)(fVar28 < 0.5) << 0x1f;
            fVar33 = fVar42;
            if (!SUB41(uVar22 >> 0x1f,0)) {
              uVar22 = uVar27 & 0xfffffff | (uint)(fVar28 < 1.0) << 0x1f |
                       (uint)(fVar28 == 1.0) << 0x1e;
              bVar2 = (byte)(uVar22 >> 0x18);
              if ((bool)(bVar2 >> 6 & 1) || (bool)(bVar2 >> 7) != NAN(fVar28)) {
                fVar33 = (fVar28 - 0.5) + (fVar28 - 0.5);
                fVar33 = (1.0 - (3.0 - (fVar33 + fVar33)) * fVar33 * fVar33) * fVar42;
              }
              else {
                fVar33 = fVar42 * DAT_00b758e8;
              }
            }
            uVar27 = uVar22 & 0xfffffff | (uint)(fVar30 == fVar33) << 0x1e |
                     (uint)(fVar33 <= fVar30) << 0x1d;
            uVar12 = uVar12 + 1;
            fVar40 = fVar40 + fVar36;
            fVar39 = fVar39 + fVar23;
            fVar42 = fVar42 + fVar35;
            bVar2 = (byte)(uVar27 >> 0x18);
            fVar43 = fVar43 + fVar44;
            if (!(bool)(bVar2 >> 5 & 1) || (bool)(bVar2 >> 6)) {
              *puVar9 = (short)param_9[4];
            }
            puVar9 = puVar9 + 1;
          } while (iVar7 + iVar6 != uVar12);
        }
      }
      fStack_b8 = fStack_b8 + fVar38;
      fVar29 = fVar29 + fVar37;
      fVar14 = fVar14 + 1.0;
      fVar26 = fVar26 + fVar34;
      fVar25 = fVar25 + fVar20;
      uVar12 = uVar27 & 0xfffffff | (uint)(fVar15 < fVar14) << 0x1f;
      uVar27 = uVar12 | (uint)(NAN(fVar15) || NAN(fVar14)) << 0x1c;
      fVar21 = fVar21 + fVar24;
      fVar41 = fVar41 + fVar3;
    } while ((byte)(uVar12 >> 0x1f) == ((byte)(uVar27 >> 0x1c) & 1));
  }
  return;
}

