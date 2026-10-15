
void FUN_00b8323c(float param_1,float param_2,float param_3,float param_4,float param_5,
                 float param_6,float param_7,float param_8,int param_9,float param_10,float param_11
                 ,float param_12,float param_13,float param_14,float param_15)

{
  bool bVar1;
  byte bVar2;
  byte bVar3;
  byte bVar4;
  byte bVar5;
  byte bVar6;
  byte bVar7;
  byte bVar8;
  uint uVar9;
  uint uVar10;
  uint uVar11;
  uint uVar12;
  uint uVar13;
  uint uVar14;
  int iVar15;
  int iVar16;
  bool bVar17;
  uint in_fpscr;
  uint uVar18;
  uint uVar19;
  float fVar20;
  float fVar21;
  float fVar22;
  float fVar23;
  float fVar24;
  float fVar25;
  float extraout_s6;
  float extraout_s7;
  float in_s8;
  float in_s9;
  float fVar26;
  float in_s10;
  float fVar27;
  float in_s11;
  float fVar28;
  float fVar29;
  float fVar30;
  float fVar31;
  float fVar32;
  float fVar33;
  int iVar34;
  uint uVar35;
  int iVar36;
  uint uVar37;
  float fVar38;
  float fVar39;
  float fVar40;
  float fVar41;
  float fVar42;
  float fVar43;
  int iVar44;
  int iVar45;
  int iVar46;
  uint uVar47;
  int iVar48;
  int iVar49;
  int iVar50;
  uint uVar51;
  float fVar52;
  float fVar53;
  float fVar54;
  float fVar55;
  float fVar56;
  float fVar57;
  float unaff_s30;
  float fVar58;
  float fVar59;
  float local_e8;
  float local_e4;
  float local_e0;
  float local_dc;
  float local_d8;
  float local_c8;
  float local_c4;
  float local_c0;
  float local_bc;
  float local_b8;
  float local_b4;
  float local_b0;
  float local_ac;
  float local_a8;
  float local_a4;
  float local_a0;
  float local_9c;
  float local_98;
  float local_94;
  float local_90;
  float local_8c;
  float local_88;
  float local_84;
  float local_80;
  float local_7c;
  
  uVar13 = in_fpscr & 0xfffffff | (uint)(param_13 < param_11) << 0x1f;
  local_dc = param_14;
  fVar20 = param_13;
  fVar53 = param_10;
  local_d8 = param_12;
  local_c8 = in_s8;
  local_c4 = in_s9;
  local_c0 = in_s10;
  local_bc = in_s11;
  local_b8 = param_5;
  local_b4 = param_6;
  local_b0 = param_7;
  local_ac = param_8;
  local_a8 = param_1;
  local_a4 = param_2;
  local_a0 = param_3;
  local_9c = param_4;
  if (SUB41(uVar13 >> 0x1f,0)) {
    FUN_00b753cc(&local_a8,&local_b8);
    fVar20 = param_11;
    param_11 = param_13;
    fVar53 = param_12;
    local_d8 = param_10;
  }
  uVar13 = uVar13 & 0xfffffff | (uint)(param_15 < param_11) << 0x1f;
  fVar31 = param_11;
  fVar57 = fVar53;
  if (SUB41(uVar13 >> 0x1f,0)) {
    FUN_00b753cc(&local_a8,&local_c8);
    fVar31 = param_15;
    param_15 = param_11;
    fVar57 = param_14;
    local_dc = fVar53;
  }
  uVar13 = uVar13 & 0xfffffff | (uint)(param_15 < fVar20) << 0x1f;
  fVar53 = fVar20;
  if (SUB41(uVar13 >> 0x1f,0)) {
    FUN_00b753cc(&local_c8,&local_b8);
    fVar38 = local_dc;
    local_dc = local_d8;
    fVar53 = param_15;
    param_15 = fVar20;
    local_d8 = fVar38;
  }
  fVar20 = floorf(fVar31);
  fVar38 = 0.5;
  uVar13 = uVar13 & 0xfffffff | (uint)(fVar31 - fVar20 < 0.5) << 0x1f;
  if (!SUB41(uVar13 >> 0x1f,0)) {
    fVar38 = 1.5;
  }
  fVar20 = fVar20 + fVar38;
  fVar38 = floorf(fVar53);
  uVar13 = uVar13 & 0xfffffff | (uint)(fVar53 - fVar38 < 0.5) << 0x1f;
  if (SUB41(uVar13 >> 0x1f,0)) {
    fVar38 = fVar38 - 0.5;
  }
  else {
    fVar38 = fVar38 + 0.5;
  }
  fVar21 = floorf(param_15);
  fVar24 = local_9c;
  fVar23 = local_a0;
  fVar22 = local_a4;
  fVar55 = local_a8;
  uVar18 = uVar13 & 0xfffffff | (uint)(fVar20 == fVar38) << 0x1e | (uint)(fVar38 <= fVar20) << 0x1d;
  if (param_15 - fVar21 < 0.5) {
    fVar21 = fVar21 - 0.5;
  }
  else {
    fVar21 = fVar21 + 0.5;
  }
  bVar2 = (byte)(uVar18 >> 0x18);
  if (!(bool)(bVar2 >> 5 & 1) || (bool)(bVar2 >> 6)) {
    fVar39 = param_15 - fVar31;
    fVar28 = fVar53 - fVar31;
    bVar17 = fVar28 == 0.0;
    fVar32 = (local_dc - fVar57) / fVar39;
    local_7c = local_b8 - local_a8;
    if (bVar17) {
      unaff_s30 = DAT_00b83724;
    }
    bVar1 = fVar39 == 0.0;
    fVar59 = (local_d8 - fVar57) / fVar28;
    local_e4 = unaff_s30;
    fVar58 = unaff_s30;
    fVar33 = fVar32;
    local_90 = unaff_s30;
    if (!bVar17) {
      local_e4 = local_7c / fVar28;
      fVar58 = local_e0;
      fVar33 = local_7c / fVar28;
      local_90 = (local_b0 - local_a0) / fVar28;
    }
    if (!bVar17) {
      fVar33 = (local_b4 - local_a4) / fVar28;
    }
    local_e0 = fVar58;
    local_8c = unaff_s30;
    if (!bVar17) {
      local_8c = (local_ac - local_9c) / fVar28;
      local_e0 = fVar33;
    }
    if (bVar1) {
      local_7c = DAT_00b83724;
    }
    local_98 = local_e4;
    local_88 = local_7c;
    local_84 = local_7c;
    local_80 = local_7c;
    if (!bVar1) {
      local_88 = (local_c8 - local_a8) / fVar39;
      local_84 = extraout_s6;
      local_80 = extraout_s7;
    }
    local_94 = local_e0;
    if (!bVar1) {
      local_84 = (local_c4 - local_a4) / fVar39;
      local_80 = (local_c0 - local_a0) / fVar39;
      local_7c = (local_bc - local_9c) / fVar39;
    }
    uVar13 = uVar13 & 0xfffffff | (uint)(fVar59 < fVar32) << 0x1f | (uint)(fVar59 == fVar32) << 0x1e
    ;
    uVar18 = uVar13 | (uint)(NAN(fVar59) || NAN(fVar32)) << 0x1c;
    bVar2 = (byte)(uVar13 >> 0x18);
    local_e8 = fVar32;
    if (!(bool)(bVar2 >> 6 & 1) && bVar2 >> 7 == ((byte)(uVar18 >> 0x1c) & 1)) {
      FUN_00b753cc(&local_98,&local_88);
      local_e4 = local_98;
      local_e0 = local_94;
      local_e8 = fVar59;
      fVar59 = fVar32;
    }
    fVar33 = fVar38 - fVar31;
    fVar40 = (fVar57 + fVar33 * local_e8) - (fVar57 + fVar33 * fVar59);
    uVar18 = uVar18 & 0xfffffff | (uint)(fVar40 == 0.0) << 0x1e;
    fVar58 = DAT_00b83724;
    fVar28 = DAT_00b83724;
    fVar32 = DAT_00b83724;
    fVar39 = DAT_00b83724;
    if (!SUB41(uVar18 >> 0x1e,0)) {
      fVar58 = ((fVar24 + fVar33 * local_7c) - (fVar24 + fVar33 * local_8c)) / fVar40;
      fVar28 = ((fVar23 + fVar33 * local_80) - (fVar23 + fVar33 * local_90)) / fVar40;
      fVar32 = ((fVar22 + fVar33 * local_84) - (fVar22 + fVar33 * local_e0)) / fVar40;
      fVar39 = ((fVar55 + fVar33 * local_88) - (fVar55 + fVar33 * local_e4)) / fVar40;
    }
    fVar40 = fVar20 - fVar31;
    fVar56 = fVar57 + fVar40 * local_e8;
    fVar33 = fVar57 + fVar40 * fVar59;
    fVar55 = fVar55 + fVar40 * local_e4;
    fVar23 = fVar23 + fVar40 * local_90;
    fVar22 = fVar22 + fVar40 * local_e0;
    fVar24 = fVar24 + fVar40 * local_8c;
    do {
      fVar40 = DAT_00b83720;
      iVar34 = (int)(fVar33 + 0.5);
      if (iVar34 <= (int)(fVar56 - 0.5)) {
        fVar41 = (float)VectorSignedToFloat(iVar34,(byte)(uVar18 >> 0x15) & 3);
        fVar25 = 1.0 / *(float *)(param_9 + 0x14);
        fVar29 = *(float *)(param_9 + 0x18);
        fVar42 = (fVar41 + 0.5) - fVar33;
        fVar30 = (float)VectorSignedToFloat((int)fVar20,(byte)(uVar18 >> 0x15) & 3);
        fVar41 = fVar23 + fVar42 * fVar28;
        fVar26 = fVar24 + fVar42 * fVar58;
        fVar30 = fVar30 - *(float *)(param_9 + 0x1c);
        iVar15 = *(int *)(param_9 + 0x24);
        fVar52 = fVar25 * fVar30;
        fVar27 = fVar55 + fVar42 * fVar39;
        fVar42 = fVar22 + fVar42 * fVar32;
        iVar16 = *(int *)(param_9 + 0x20);
        fVar54 = fVar25 * 3.0 * fVar30;
        fVar30 = fVar25 * 7.0 * fVar30;
        uVar13 = (int)fVar52 - 1;
        if (0.0 <= fVar52) {
          uVar13 = (int)fVar52;
        }
        uVar18 = uVar18 & 0xfffffff | (uint)(fVar30 < 0.0) << 0x1f;
        fVar43 = (float)VectorSignedToFloat(uVar13,(byte)(uVar18 >> 0x15) & 3);
        iVar44 = (int)((fVar52 - fVar43) * DAT_00b83720);
        bVar2 = (&DAT_011dd648)[uVar13 & 0xff];
        bVar3 = (&DAT_011dd648)[uVar13 + 1 & 0xff];
        uVar13 = (int)fVar54 - 1;
        if (0.0 <= fVar54) {
          uVar13 = (int)fVar54;
        }
        uVar35 = (int)fVar30 - 1;
        if (!SUB41(uVar18 >> 0x1f,0)) {
          uVar35 = (int)fVar30;
        }
        fVar52 = (float)VectorSignedToFloat(uVar13,(byte)(uVar18 >> 0x15) & 3);
        bVar4 = (&DAT_011dd648)[uVar13 & 0xff];
        bVar5 = (&DAT_011dd648)[uVar13 + 1 & 0xff];
        bVar6 = (&DAT_011dd648)[uVar35 + 1 & 0xff];
        bVar7 = (&DAT_011dd648)[uVar35 & 0xff];
        fVar43 = (float)VectorSignedToFloat(uVar35,(byte)(uVar18 >> 0x15) & 3);
        iVar49 = (int)((fVar54 - fVar52) * DAT_00b83720);
        iVar45 = (int)((fVar30 - fVar43) * DAT_00b83720);
        do {
          fVar30 = (float)VectorSignedToFloat(iVar34,(byte)(uVar18 >> 0x15) & 3);
          fVar30 = fVar30 - fVar29;
          fVar52 = fVar25 * fVar30;
          uVar18 = uVar18 & 0xfffffff;
          uVar13 = uVar18 | (uint)(fVar52 < 0.0) << 0x1f;
          uVar35 = (uint)fVar52;
          if (SUB41(uVar13 >> 0x1f,0)) {
            uVar9 = uVar35;
            uVar35 = uVar35 - 1;
          }
          else {
            uVar9 = uVar35 + 1;
          }
          fVar43 = (float)VectorSignedToFloat(uVar35,(byte)(uVar13 >> 0x15) & 3);
          fVar54 = fVar25 * 3.0 * fVar30;
          iVar50 = (int)((fVar52 - fVar43) * fVar40);
          fVar30 = fVar25 * 7.0 * fVar30;
          uVar51 = (uint)fVar54;
          uVar13 = uVar18 | (uint)(fVar30 < 0.0) << 0x1f;
          if (fVar54 < 0.0) {
            uVar10 = uVar51;
            uVar51 = uVar51 - 1;
          }
          else {
            uVar10 = uVar51 + 1;
          }
          fVar52 = (float)VectorSignedToFloat(uVar51,(byte)(uVar13 >> 0x15) & 3);
          iVar36 = (int)((fVar54 - fVar52) * fVar40);
          uVar37 = (uint)fVar30;
          if (SUB41(uVar13 >> 0x1f,0)) {
            uVar13 = uVar37;
            uVar37 = uVar37 - 1;
          }
          else {
            uVar13 = uVar37 + 1;
          }
          uVar19 = uVar18 | (uint)(fVar42 < 0.0) << 0x1f;
          fVar52 = (float)VectorSignedToFloat(uVar37,(byte)(uVar19 >> 0x15) & 3);
          iVar46 = (int)((fVar30 - fVar52) * fVar40);
          uVar47 = (uint)fVar27;
          uVar13 = (int)((0xff - iVar45) *
                         ((0xff - iVar46) *
                          (uint)(byte)(&DAT_011dd610)[(uVar37 & 0xff) + (uint)bVar7 + 0x38] +
                         iVar46 * (uint)(byte)(&DAT_011dd610)[(uVar13 & 0xff) + (uint)bVar7 + 0x38])
                        + iVar45 * ((0xff - iVar46) *
                                    (uint)(byte)(&DAT_011dd648)[(uVar37 & 0xff) + (uint)bVar6] +
                                   iVar46 * (uint)(byte)(&DAT_011dd648)
                                                        [(uint)bVar6 + (uVar13 & 0xff)])) >> 0x10;
          uVar37 = (uint)fVar42;
          if (fVar27 < 0.0) {
            uVar12 = uVar47 - 1;
          }
          else {
            uVar12 = uVar47;
            uVar47 = uVar47 + 1;
          }
          bVar17 = SUB41(uVar19 >> 0x1f,0);
          uVar19 = uVar18 | (uint)(fVar26 < 2.0) << 0x1f | (uint)(fVar26 == 2.0) << 0x1e;
          uVar14 = uVar37;
          uVar11 = (uint)((ulonglong)uVar13 * 0xaaaaaaab >> 0x20);
          if (bVar17) {
            uVar14 = uVar37 - 1;
            uVar11 = uVar37;
          }
          if (!bVar17) {
            uVar11 = uVar14 + 1;
          }
          fVar30 = (float)VectorSignedToFloat(uVar12,(byte)(uVar19 >> 0x15) & 3);
          fVar52 = (float)VectorSignedToFloat(uVar14,(byte)(uVar19 >> 0x15) & 3);
          iVar46 = (int)((fVar27 - fVar30) * fVar40);
          iVar48 = (int)((fVar42 - fVar52) * fVar40);
          bVar8 = (byte)(uVar19 >> 0x18);
          fVar30 = fVar41;
          if (!(bool)(bVar8 >> 6 & 1) && (bool)(bVar8 >> 7) == NAN(fVar26)) {
            fVar52 = ABS(fVar42) / fVar26;
            uVar19 = uVar18 | (uint)(fVar52 < 0.5) << 0x1f;
            if (!SUB41(uVar19 >> 0x1f,0)) {
              uVar19 = uVar18 | (uint)(fVar52 < 1.0) << 0x1f | (uint)(fVar52 == 1.0) << 0x1e;
              bVar8 = (byte)(uVar19 >> 0x18);
              fVar30 = DAT_00b83724;
              if ((bool)(bVar8 >> 6 & 1) || (bool)(bVar8 >> 7) != NAN(fVar52)) {
                fVar30 = (fVar52 - 0.5) + (fVar52 - 0.5);
                fVar30 = 1.0 - (3.0 - (fVar30 + fVar30)) * fVar30 * fVar30;
              }
              fVar30 = fVar30 * fVar41;
            }
          }
          fVar27 = fVar27 + fVar39;
          fVar42 = fVar42 + fVar32;
          fVar41 = fVar41 + fVar28;
          fVar52 = (float)VectorSignedToFloat((((uint)(((int)((0xff - iVar44) *
                                                              ((0xff - iVar50) *
                                                               (uint)(byte)(&DAT_011dd610)
                                                                           [(uVar35 & 0xff) +
                                                                            (uint)bVar2 + 0x38] +
                                                              iVar50 * (uint)(byte)(&DAT_011dd610)
                                                                                   [(uVar9 & 0xff) +
                                                                                    (uint)bVar2 +
                                                                                    0x38]) +
                                                             iVar44 * ((0xff - iVar50) *
                                                                       (uint)(byte)(&DAT_011dd648)
                                                                                   [(uVar35 & 0xff)
                                                                                    + (uint)bVar3] +
                                                                      iVar50 * (uint)(byte)(&
                                                  DAT_011dd648)[(uint)bVar3 + (uVar9 & 0xff)])) >>
                                                  0x10) << 1) / 6 +
                                                (uint)(((int)((0xff - iVar49) *
                                                              ((0xff - iVar36) *
                                                               (uint)(byte)(&DAT_011dd610)
                                                                           [(uVar51 & 0xff) +
                                                                            (uint)bVar4 + 0x38] +
                                                              iVar36 * (uint)(byte)(&DAT_011dd610)
                                                                                   [(uVar10 & 0xff)
                                                                                    + (uint)bVar4 +
                                                                                    0x38]) +
                                                             iVar49 * ((0xff - iVar36) *
                                                                       (uint)(byte)(&DAT_011dd648)
                                                                                   [(uVar51 & 0xff)
                                                                                    + (uint)bVar5] +
                                                                      iVar36 * (uint)(byte)(&
                                                  DAT_011dd648)[(uint)bVar5 + (uVar10 & 0xff)])) >>
                                                  0x10) * 3) / 6 + uVar13 / 6) * 7 >> 3) +
                                              ((uint)((int)((0xff - iVar48) *
                                                            ((0xff - iVar46) *
                                                             (uint)(byte)(&DAT_011dd610)
                                                                         [(uVar12 & 0xff) +
                                                                          (uint)(byte)(&DAT_011dd648
                                                                                      )[uVar14 & 
                                                  0xff] + 0x38] +
                                                  iVar46 * (uint)(byte)(&DAT_011dd610)
                                                                       [(uVar47 & 0xff) +
                                                                        (uint)(byte)(&DAT_011dd648)
                                                                                    [uVar14 & 0xff]
                                                                        + 0x38]) +
                                                  iVar48 * ((0xff - iVar46) *
                                                            (uint)(byte)(&DAT_011dd648)
                                                                        [(uVar12 & 0xff) +
                                                                         (uint)(byte)(&DAT_011dd648)
                                                                                     [uVar11 & 0xff]
                                                                        ] +
                                                           iVar46 * (uint)(byte)(&DAT_011dd648)
                                                                                [(uint)(byte)(&
                                                  DAT_011dd648)[uVar11 & 0xff] + (uVar47 & 0xff)]))
                                                  >> 0x10) >> 3),(byte)(uVar19 >> 0x15) & 3);
          fVar26 = fVar26 + fVar58;
          uVar18 = uVar19 & 0xfffffff | (uint)(fVar52 == fVar30) << 0x1e |
                   (uint)(fVar30 <= fVar52) << 0x1d;
          bVar8 = (byte)(uVar18 >> 0x18);
          if (!(bool)(bVar8 >> 5 & 1) || (bool)(bVar8 >> 6)) {
            *(undefined4 *)(iVar16 + iVar15 * (int)fVar20 * 4 + iVar34 * 4) =
                 *(undefined4 *)(param_9 + 0x28);
          }
          iVar34 = iVar34 + 1;
        } while ((int)(fVar56 - 0.5) + 1 != iVar34);
      }
      fVar20 = fVar20 + 1.0;
      fVar33 = fVar33 + fVar59;
      fVar56 = fVar56 + local_e8;
      uVar13 = uVar18 & 0xfffffff | (uint)(fVar38 < fVar20) << 0x1f;
      uVar18 = uVar13 | (uint)(NAN(fVar38) || NAN(fVar20)) << 0x1c;
      fVar23 = fVar23 + local_90;
      fVar55 = fVar55 + local_e4;
      fVar24 = fVar24 + local_8c;
      fVar22 = fVar22 + local_e0;
    } while ((byte)(uVar13 >> 0x1f) == ((byte)(uVar18 >> 0x1c) & 1));
  }
  if (fVar20 <= fVar21) {
    fVar53 = param_15 - fVar53;
    bVar17 = fVar53 != 0.0;
    fVar55 = (local_dc - local_d8) / fVar53;
    fVar31 = param_15 - fVar31;
    fVar38 = local_ac;
    if (bVar17) {
      fVar38 = (local_c8 - local_b8) / fVar53;
    }
    fVar22 = (local_dc - fVar57) / fVar31;
    local_94 = DAT_00b83724;
    local_8c = DAT_00b83724;
    local_e8 = DAT_00b83724;
    if (bVar17) {
      local_94 = (local_c4 - local_b4) / fVar53;
      local_8c = local_dc - fVar57;
      local_e8 = fVar38;
    }
    local_90 = local_e8;
    if (bVar17) {
      local_90 = (local_c0 - local_b0) / fVar53;
    }
    if (bVar17) {
      local_8c = (local_bc - local_ac) / fVar53;
    }
    uVar13 = uVar18 & 0xfffffff | (uint)(fVar55 < fVar22) << 0x1f;
    local_7c = DAT_00b83e44;
    local_84 = DAT_00b83e44;
    local_88 = DAT_00b83e44;
    local_80 = DAT_00b83e44;
    if (fVar31 != 0.0) {
      local_88 = (local_c8 - local_a8) / fVar31;
      local_84 = (local_c4 - local_a4) / fVar31;
      local_80 = (local_c0 - local_a0) / fVar31;
      local_7c = (local_bc - local_9c) / fVar31;
    }
    fVar53 = fVar55;
    if (SUB41(uVar13 >> 0x1f,0)) {
      local_98 = local_e8;
      FUN_00b753cc(&local_98,&local_88);
      local_e8 = local_98;
      fVar53 = fVar22;
      fVar22 = fVar55;
    }
    param_15 = param_15 - fVar20;
    fVar23 = local_dc - param_15 * fVar22;
    local_dc = local_dc - param_15 * fVar53;
    fVar32 = local_c4 - param_15 * local_94;
    fVar39 = local_c0 - param_15 * local_90;
    fVar58 = local_bc - param_15 * local_8c;
    fVar28 = local_c8 - param_15 * local_e8;
    fVar24 = fVar23 - local_dc;
    uVar13 = uVar13 & 0xfffffff | (uint)(fVar24 == 0.0) << 0x1e;
    fVar38 = DAT_00b83e44;
    fVar57 = DAT_00b83e44;
    fVar31 = DAT_00b83e44;
    fVar55 = DAT_00b83e44;
    if (!SUB41(uVar13 >> 0x1e,0)) {
      fVar38 = ((local_c4 - param_15 * local_84) - fVar32) / fVar24;
      fVar57 = ((local_c8 - param_15 * local_88) - fVar28) / fVar24;
      fVar31 = ((local_c0 - param_15 * local_80) - fVar39) / fVar24;
      fVar55 = ((local_bc - param_15 * local_7c) - fVar58) / fVar24;
    }
    do {
      fVar24 = DAT_00b83e40;
      iVar34 = (int)(local_dc + 0.5);
      if (iVar34 <= (int)(fVar23 - 0.5)) {
        fVar33 = 1.0 / *(float *)(param_9 + 0x14);
        fVar59 = (float)VectorSignedToFloat(iVar34,(byte)(uVar13 >> 0x15) & 3);
        fVar41 = (float)VectorSignedToFloat((int)fVar20,(byte)(uVar13 >> 0x15) & 3);
        fVar25 = (fVar59 + 0.5) - local_dc;
        fVar41 = fVar41 - *(float *)(param_9 + 0x1c);
        fVar56 = fVar28 + fVar25 * fVar57;
        fVar59 = fVar39 + fVar25 * fVar31;
        fVar40 = fVar58 + fVar25 * fVar55;
        fVar25 = fVar32 + fVar25 * fVar38;
        fVar26 = fVar33 * fVar41;
        fVar27 = fVar33 * 3.0 * fVar41;
        iVar15 = *(int *)(param_9 + 0x24);
        uVar18 = uVar13 & 0xfffffff | (uint)(fVar27 < 0.0) << 0x1f;
        uVar35 = (int)fVar26 - 1;
        if (0.0 <= fVar26) {
          uVar35 = (int)fVar26;
        }
        iVar16 = *(int *)(param_9 + 0x20);
        fVar41 = fVar33 * 7.0 * fVar41;
        fVar30 = (float)VectorSignedToFloat(uVar35,(byte)(uVar18 >> 0x15) & 3);
        uVar13 = uVar13 & 0xfffffff | (uint)(fVar41 < 0.0) << 0x1f;
        fVar29 = *(float *)(param_9 + 0x18);
        iVar44 = (int)((fVar26 - fVar30) * DAT_00b83e40);
        bVar2 = (&DAT_011dd648)[uVar35 & 0xff];
        bVar3 = (&DAT_011dd648)[uVar35 + 1 & 0xff];
        uVar35 = (int)fVar27 - 1;
        if (!SUB41(uVar18 >> 0x1f,0)) {
          uVar35 = (int)fVar27;
        }
        uVar18 = (int)fVar41 - 1;
        if (!SUB41(uVar13 >> 0x1f,0)) {
          uVar18 = (int)fVar41;
        }
        fVar26 = (float)VectorSignedToFloat(uVar35,(byte)(uVar13 >> 0x15) & 3);
        bVar4 = (&DAT_011dd648)[uVar35 & 0xff];
        bVar5 = (&DAT_011dd648)[uVar35 + 1 & 0xff];
        bVar6 = (&DAT_011dd648)[uVar18 + 1 & 0xff];
        bVar7 = (&DAT_011dd648)[uVar18 & 0xff];
        fVar30 = (float)VectorSignedToFloat(uVar18,(byte)(uVar13 >> 0x15) & 3);
        iVar45 = (int)((fVar27 - fVar26) * DAT_00b83e40);
        iVar49 = (int)((fVar41 - fVar30) * DAT_00b83e40);
        do {
          fVar26 = (float)VectorSignedToFloat(iVar34,(byte)(uVar13 >> 0x15) & 3);
          fVar26 = fVar26 - fVar29;
          fVar41 = fVar33 * fVar26;
          uVar13 = uVar13 & 0xfffffff;
          uVar18 = uVar13 | (uint)(fVar41 < 0.0) << 0x1f;
          uVar35 = (uint)fVar41;
          if (SUB41(uVar18 >> 0x1f,0)) {
            uVar9 = uVar35;
            uVar35 = uVar35 - 1;
          }
          else {
            uVar9 = uVar35 + 1;
          }
          fVar30 = (float)VectorSignedToFloat(uVar35,(byte)(uVar18 >> 0x15) & 3);
          fVar27 = fVar33 * 3.0 * fVar26;
          iVar50 = (int)((fVar41 - fVar30) * fVar24);
          fVar26 = fVar33 * 7.0 * fVar26;
          uVar51 = (uint)fVar27;
          uVar18 = uVar13 | (uint)(fVar26 < 0.0) << 0x1f;
          if (fVar27 < 0.0) {
            uVar10 = uVar51;
            uVar51 = uVar51 - 1;
          }
          else {
            uVar10 = uVar51 + 1;
          }
          fVar41 = (float)VectorSignedToFloat(uVar51,(byte)(uVar18 >> 0x15) & 3);
          iVar36 = (int)((fVar27 - fVar41) * fVar24);
          uVar37 = (uint)fVar26;
          if (SUB41(uVar18 >> 0x1f,0)) {
            uVar18 = uVar37;
            uVar37 = uVar37 - 1;
          }
          else {
            uVar18 = uVar37 + 1;
          }
          uVar19 = uVar13 | (uint)(fVar25 < 0.0) << 0x1f;
          fVar41 = (float)VectorSignedToFloat(uVar37,(byte)(uVar19 >> 0x15) & 3);
          iVar46 = (int)((fVar26 - fVar41) * fVar24);
          uVar47 = (uint)fVar56;
          uVar18 = (int)((0xff - iVar49) *
                         ((0xff - iVar46) *
                          (uint)(byte)(&DAT_011dd610)[(uVar37 & 0xff) + (uint)bVar7 + 0x38] +
                         iVar46 * (uint)(byte)(&DAT_011dd610)[(uVar18 & 0xff) + (uint)bVar7 + 0x38])
                        + iVar49 * ((0xff - iVar46) *
                                    (uint)(byte)(&DAT_011dd648)[(uVar37 & 0xff) + (uint)bVar6] +
                                   iVar46 * (uint)(byte)(&DAT_011dd648)
                                                        [(uint)bVar6 + (uVar18 & 0xff)])) >> 0x10;
          uVar37 = (uint)fVar25;
          if (fVar56 < 0.0) {
            uVar12 = uVar47 - 1;
          }
          else {
            uVar12 = uVar47;
            uVar47 = uVar47 + 1;
          }
          bVar17 = SUB41(uVar19 >> 0x1f,0);
          uVar19 = uVar13 | (uint)(fVar40 < 2.0) << 0x1f | (uint)(fVar40 == 2.0) << 0x1e;
          uVar14 = uVar37;
          uVar11 = (uint)((ulonglong)uVar18 * 0xaaaaaaab >> 0x20);
          if (bVar17) {
            uVar14 = uVar37 - 1;
            uVar11 = uVar37;
          }
          if (!bVar17) {
            uVar11 = uVar14 + 1;
          }
          fVar41 = (float)VectorSignedToFloat(uVar12,(byte)(uVar19 >> 0x15) & 3);
          fVar26 = (float)VectorSignedToFloat(uVar14,(byte)(uVar19 >> 0x15) & 3);
          iVar46 = (int)((fVar56 - fVar41) * fVar24);
          iVar48 = (int)((fVar25 - fVar26) * fVar24);
          bVar8 = (byte)(uVar19 >> 0x18);
          fVar41 = fVar59;
          if (!(bool)(bVar8 >> 6 & 1) && (bool)(bVar8 >> 7) == NAN(fVar40)) {
            fVar26 = ABS(fVar25) / fVar40;
            uVar19 = uVar13 | (uint)(fVar26 < 0.5) << 0x1f;
            if (!SUB41(uVar19 >> 0x1f,0)) {
              uVar19 = uVar13 | (uint)(fVar26 < 1.0) << 0x1f | (uint)(fVar26 == 1.0) << 0x1e;
              bVar8 = (byte)(uVar19 >> 0x18);
              fVar41 = DAT_00b83e44;
              if ((bool)(bVar8 >> 6 & 1) || (bool)(bVar8 >> 7) != NAN(fVar26)) {
                fVar41 = (fVar26 - 0.5) + (fVar26 - 0.5);
                fVar41 = 1.0 - (3.0 - (fVar41 + fVar41)) * fVar41 * fVar41;
              }
              fVar41 = fVar41 * fVar59;
            }
          }
          fVar56 = fVar56 + fVar57;
          fVar25 = fVar25 + fVar38;
          fVar59 = fVar59 + fVar31;
          fVar26 = (float)VectorSignedToFloat((((uint)(((int)((0xff - iVar44) *
                                                              ((0xff - iVar50) *
                                                               (uint)(byte)(&DAT_011dd610)
                                                                           [(uVar35 & 0xff) +
                                                                            (uint)bVar2 + 0x38] +
                                                              iVar50 * (uint)(byte)(&DAT_011dd610)
                                                                                   [(uVar9 & 0xff) +
                                                                                    (uint)bVar2 +
                                                                                    0x38]) +
                                                             iVar44 * ((0xff - iVar50) *
                                                                       (uint)(byte)(&DAT_011dd648)
                                                                                   [(uVar35 & 0xff)
                                                                                    + (uint)bVar3] +
                                                                      iVar50 * (uint)(byte)(&
                                                  DAT_011dd648)[(uint)bVar3 + (uVar9 & 0xff)])) >>
                                                  0x10) << 1) / 6 +
                                                (uint)(((int)((0xff - iVar45) *
                                                              ((0xff - iVar36) *
                                                               (uint)(byte)(&DAT_011dd610)
                                                                           [(uVar51 & 0xff) +
                                                                            (uint)bVar4 + 0x38] +
                                                              iVar36 * (uint)(byte)(&DAT_011dd610)
                                                                                   [(uVar10 & 0xff)
                                                                                    + (uint)bVar4 +
                                                                                    0x38]) +
                                                             iVar45 * ((0xff - iVar36) *
                                                                       (uint)(byte)(&DAT_011dd648)
                                                                                   [(uVar51 & 0xff)
                                                                                    + (uint)bVar5] +
                                                                      iVar36 * (uint)(byte)(&
                                                  DAT_011dd648)[(uint)bVar5 + (uVar10 & 0xff)])) >>
                                                  0x10) * 3) / 6 + uVar18 / 6) * 7 >> 3) +
                                              ((uint)((int)((0xff - iVar48) *
                                                            ((0xff - iVar46) *
                                                             (uint)(byte)(&DAT_011dd610)
                                                                         [(uVar12 & 0xff) +
                                                                          (uint)(byte)(&DAT_011dd648
                                                                                      )[uVar14 & 
                                                  0xff] + 0x38] +
                                                  iVar46 * (uint)(byte)(&DAT_011dd610)
                                                                       [(uVar47 & 0xff) +
                                                                        (uint)(byte)(&DAT_011dd648)
                                                                                    [uVar14 & 0xff]
                                                                        + 0x38]) +
                                                  iVar48 * ((0xff - iVar46) *
                                                            (uint)(byte)(&DAT_011dd648)
                                                                        [(uVar12 & 0xff) +
                                                                         (uint)(byte)(&DAT_011dd648)
                                                                                     [uVar11 & 0xff]
                                                                        ] +
                                                           iVar46 * (uint)(byte)(&DAT_011dd648)
                                                                                [(uint)(byte)(&
                                                  DAT_011dd648)[uVar11 & 0xff] + (uVar47 & 0xff)]))
                                                  >> 0x10) >> 3),(byte)(uVar19 >> 0x15) & 3);
          fVar40 = fVar40 + fVar55;
          uVar13 = uVar19 & 0xfffffff | (uint)(fVar26 == fVar41) << 0x1e |
                   (uint)(fVar41 <= fVar26) << 0x1d;
          bVar8 = (byte)(uVar13 >> 0x18);
          if (!(bool)(bVar8 >> 5 & 1) || (bool)(bVar8 >> 6)) {
            *(undefined4 *)(iVar16 + iVar15 * (int)fVar20 * 4 + iVar34 * 4) =
                 *(undefined4 *)(param_9 + 0x28);
          }
          iVar34 = iVar34 + 1;
        } while ((int)(fVar23 - 0.5) + 1 != iVar34);
      }
      fVar20 = fVar20 + 1.0;
      local_dc = local_dc + fVar53;
      fVar23 = fVar23 + fVar22;
      uVar13 = uVar13 & 0xfffffff | (uint)(fVar21 < fVar20) << 0x1f;
      fVar28 = fVar28 + local_e8;
      fVar32 = fVar32 + local_94;
      fVar39 = fVar39 + local_90;
      fVar58 = fVar58 + local_8c;
    } while (SUB41(uVar13 >> 0x1f,0) == (NAN(fVar21) || NAN(fVar20)));
  }
  return;
}

