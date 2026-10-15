
void FUN_00b84324(float param_1,float param_2,float param_3,float param_4,float param_5,
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
  undefined2 *puVar15;
  bool bVar16;
  uint in_fpscr;
  uint uVar17;
  uint uVar18;
  float fVar19;
  float fVar20;
  float fVar21;
  float fVar22;
  float fVar23;
  float fVar24;
  float extraout_s6;
  float extraout_s7;
  float in_s8;
  float in_s9;
  float fVar25;
  float in_s10;
  float fVar26;
  float in_s11;
  float fVar27;
  float fVar28;
  float fVar29;
  float fVar30;
  float fVar31;
  float fVar32;
  int iVar33;
  uint uVar34;
  int iVar35;
  uint uVar36;
  float fVar37;
  float fVar38;
  float fVar39;
  float fVar40;
  float fVar41;
  float fVar42;
  int iVar43;
  int iVar44;
  int iVar45;
  uint uVar46;
  int iVar47;
  int iVar48;
  int iVar49;
  uint uVar50;
  float fVar51;
  float fVar52;
  float fVar53;
  float fVar54;
  float fVar55;
  float fVar56;
  float unaff_s30;
  float fVar57;
  float fVar58;
  float local_ec;
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
  fVar19 = param_13;
  fVar52 = param_10;
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
    fVar19 = param_11;
    param_11 = param_13;
    fVar52 = param_12;
    local_d8 = param_10;
  }
  uVar13 = uVar13 & 0xfffffff | (uint)(param_15 < param_11) << 0x1f;
  fVar30 = param_11;
  fVar56 = fVar52;
  if (SUB41(uVar13 >> 0x1f,0)) {
    FUN_00b753cc(&local_a8,&local_c8);
    fVar30 = param_15;
    param_15 = param_11;
    fVar56 = param_14;
    local_dc = fVar52;
  }
  uVar13 = uVar13 & 0xfffffff | (uint)(param_15 < fVar19) << 0x1f;
  fVar52 = fVar19;
  if (SUB41(uVar13 >> 0x1f,0)) {
    FUN_00b753cc(&local_c8,&local_b8);
    fVar37 = local_dc;
    local_dc = local_d8;
    fVar52 = param_15;
    param_15 = fVar19;
    local_d8 = fVar37;
  }
  fVar19 = floorf(fVar30);
  fVar37 = 0.5;
  uVar13 = uVar13 & 0xfffffff | (uint)(fVar30 - fVar19 < 0.5) << 0x1f;
  if (!SUB41(uVar13 >> 0x1f,0)) {
    fVar37 = 1.5;
  }
  fVar19 = fVar19 + fVar37;
  fVar37 = floorf(fVar52);
  uVar13 = uVar13 & 0xfffffff | (uint)(fVar52 - fVar37 < 0.5) << 0x1f;
  if (SUB41(uVar13 >> 0x1f,0)) {
    fVar37 = fVar37 - 0.5;
  }
  else {
    fVar37 = fVar37 + 0.5;
  }
  fVar20 = floorf(param_15);
  fVar23 = local_9c;
  fVar22 = local_a0;
  fVar21 = local_a4;
  fVar54 = local_a8;
  uVar17 = uVar13 & 0xfffffff | (uint)(fVar19 == fVar37) << 0x1e | (uint)(fVar37 <= fVar19) << 0x1d;
  if (param_15 - fVar20 < 0.5) {
    fVar20 = fVar20 - 0.5;
  }
  else {
    fVar20 = fVar20 + 0.5;
  }
  bVar2 = (byte)(uVar17 >> 0x18);
  if (!(bool)(bVar2 >> 5 & 1) || (bool)(bVar2 >> 6)) {
    fVar38 = param_15 - fVar30;
    fVar27 = fVar52 - fVar30;
    bVar16 = fVar27 == 0.0;
    fVar31 = (local_dc - fVar56) / fVar38;
    local_7c = local_b8 - local_a8;
    if (bVar16) {
      unaff_s30 = DAT_00b8480c;
    }
    bVar1 = fVar38 == 0.0;
    fVar58 = (local_d8 - fVar56) / fVar27;
    local_e4 = unaff_s30;
    fVar57 = unaff_s30;
    fVar32 = fVar31;
    local_90 = unaff_s30;
    if (!bVar16) {
      local_e4 = local_7c / fVar27;
      fVar57 = local_e0;
      fVar32 = local_7c / fVar27;
      local_90 = (local_b0 - local_a0) / fVar27;
    }
    if (!bVar16) {
      fVar32 = (local_b4 - local_a4) / fVar27;
    }
    local_e0 = fVar57;
    local_8c = unaff_s30;
    if (!bVar16) {
      local_8c = (local_ac - local_9c) / fVar27;
      local_e0 = fVar32;
    }
    if (bVar1) {
      local_7c = DAT_00b8480c;
    }
    local_98 = local_e4;
    local_88 = local_7c;
    local_84 = local_7c;
    local_80 = local_7c;
    if (!bVar1) {
      local_88 = (local_c8 - local_a8) / fVar38;
      local_84 = extraout_s6;
      local_80 = extraout_s7;
    }
    local_94 = local_e0;
    if (!bVar1) {
      local_84 = (local_c4 - local_a4) / fVar38;
      local_80 = (local_c0 - local_a0) / fVar38;
      local_7c = (local_bc - local_9c) / fVar38;
    }
    uVar13 = uVar13 & 0xfffffff | (uint)(fVar58 < fVar31) << 0x1f | (uint)(fVar58 == fVar31) << 0x1e
    ;
    uVar17 = uVar13 | (uint)(NAN(fVar58) || NAN(fVar31)) << 0x1c;
    bVar2 = (byte)(uVar13 >> 0x18);
    local_e8 = fVar31;
    if (!(bool)(bVar2 >> 6 & 1) && bVar2 >> 7 == ((byte)(uVar17 >> 0x1c) & 1)) {
      FUN_00b753cc(&local_98,&local_88);
      local_e4 = local_98;
      local_e0 = local_94;
      local_e8 = fVar58;
      fVar58 = fVar31;
    }
    fVar32 = fVar37 - fVar30;
    fVar39 = (fVar56 + fVar32 * local_e8) - (fVar56 + fVar32 * fVar58);
    uVar17 = uVar17 & 0xfffffff | (uint)(fVar39 == 0.0) << 0x1e;
    fVar57 = DAT_00b8480c;
    fVar27 = DAT_00b8480c;
    fVar31 = DAT_00b8480c;
    fVar38 = DAT_00b8480c;
    if (!SUB41(uVar17 >> 0x1e,0)) {
      fVar57 = ((fVar23 + fVar32 * local_7c) - (fVar23 + fVar32 * local_8c)) / fVar39;
      fVar27 = ((fVar22 + fVar32 * local_80) - (fVar22 + fVar32 * local_90)) / fVar39;
      fVar31 = ((fVar21 + fVar32 * local_84) - (fVar21 + fVar32 * local_e0)) / fVar39;
      fVar38 = ((fVar54 + fVar32 * local_88) - (fVar54 + fVar32 * local_e4)) / fVar39;
    }
    fVar39 = fVar19 - fVar30;
    fVar55 = fVar56 + fVar39 * local_e8;
    fVar32 = fVar56 + fVar39 * fVar58;
    fVar54 = fVar54 + fVar39 * local_e4;
    fVar22 = fVar22 + fVar39 * local_90;
    fVar21 = fVar21 + fVar39 * local_e0;
    fVar23 = fVar23 + fVar39 * local_8c;
    do {
      fVar39 = DAT_00b84808;
      iVar33 = (int)(fVar32 + 0.5);
      if (iVar33 <= (int)(fVar55 - 0.5)) {
        fVar40 = (float)VectorSignedToFloat(iVar33,(byte)(uVar17 >> 0x15) & 3);
        fVar24 = 1.0 / *(float *)(param_9 + 0x14);
        fVar28 = *(float *)(param_9 + 0x18);
        fVar41 = (fVar40 + 0.5) - fVar32;
        fVar29 = (float)VectorSignedToFloat((int)fVar19,(byte)(uVar17 >> 0x15) & 3);
        fVar40 = fVar22 + fVar41 * fVar27;
        fVar25 = fVar23 + fVar41 * fVar57;
        fVar29 = fVar29 - *(float *)(param_9 + 0x1c);
        fVar51 = fVar24 * fVar29;
        fVar26 = fVar54 + fVar41 * fVar38;
        fVar41 = fVar21 + fVar41 * fVar31;
        fVar53 = fVar24 * 3.0 * fVar29;
        fVar29 = fVar24 * 7.0 * fVar29;
        uVar13 = (int)fVar51 - 1;
        if (0.0 <= fVar51) {
          uVar13 = (int)fVar51;
        }
        uVar17 = uVar17 & 0xfffffff | (uint)(fVar29 < 0.0) << 0x1f;
        fVar42 = (float)VectorSignedToFloat(uVar13,(byte)(uVar17 >> 0x15) & 3);
        iVar43 = (int)((fVar51 - fVar42) * DAT_00b84808);
        bVar2 = (&DAT_011dd648)[uVar13 & 0xff];
        bVar3 = (&DAT_011dd648)[uVar13 + 1 & 0xff];
        uVar13 = (int)fVar53 - 1;
        if (0.0 <= fVar53) {
          uVar13 = (int)fVar53;
        }
        uVar34 = (int)fVar29 - 1;
        if (!SUB41(uVar17 >> 0x1f,0)) {
          uVar34 = (int)fVar29;
        }
        fVar51 = (float)VectorSignedToFloat(uVar13,(byte)(uVar17 >> 0x15) & 3);
        bVar4 = (&DAT_011dd648)[uVar13 & 0xff];
        bVar5 = (&DAT_011dd648)[uVar13 + 1 & 0xff];
        bVar6 = (&DAT_011dd648)[uVar34 + 1 & 0xff];
        bVar7 = (&DAT_011dd648)[uVar34 & 0xff];
        fVar42 = (float)VectorSignedToFloat(uVar34,(byte)(uVar17 >> 0x15) & 3);
        iVar48 = (int)((fVar53 - fVar51) * DAT_00b84808);
        iVar44 = (int)((fVar29 - fVar42) * DAT_00b84808);
        puVar15 = (undefined2 *)
                  (*(int *)(param_9 + 0x20) + (*(int *)(param_9 + 0x24) * (int)fVar19 + iVar33) * 2)
        ;
        do {
          fVar29 = (float)VectorSignedToFloat(iVar33,(byte)(uVar17 >> 0x15) & 3);
          fVar29 = fVar29 - fVar28;
          fVar51 = fVar24 * fVar29;
          uVar17 = uVar17 & 0xfffffff;
          uVar13 = uVar17 | (uint)(fVar51 < 0.0) << 0x1f;
          uVar34 = (uint)fVar51;
          if (SUB41(uVar13 >> 0x1f,0)) {
            uVar9 = uVar34;
            uVar34 = uVar34 - 1;
          }
          else {
            uVar9 = uVar34 + 1;
          }
          fVar42 = (float)VectorSignedToFloat(uVar34,(byte)(uVar13 >> 0x15) & 3);
          fVar53 = fVar24 * 3.0 * fVar29;
          iVar49 = (int)((fVar51 - fVar42) * fVar39);
          fVar29 = fVar24 * 7.0 * fVar29;
          uVar50 = (uint)fVar53;
          uVar13 = uVar17 | (uint)(fVar29 < 0.0) << 0x1f;
          if (fVar53 < 0.0) {
            uVar10 = uVar50;
            uVar50 = uVar50 - 1;
          }
          else {
            uVar10 = uVar50 + 1;
          }
          fVar51 = (float)VectorSignedToFloat(uVar50,(byte)(uVar13 >> 0x15) & 3);
          iVar35 = (int)((fVar53 - fVar51) * fVar39);
          uVar36 = (uint)fVar29;
          if (SUB41(uVar13 >> 0x1f,0)) {
            uVar13 = uVar36;
            uVar36 = uVar36 - 1;
          }
          else {
            uVar13 = uVar36 + 1;
          }
          uVar18 = uVar17 | (uint)(fVar41 < 0.0) << 0x1f;
          fVar51 = (float)VectorSignedToFloat(uVar36,(byte)(uVar18 >> 0x15) & 3);
          iVar45 = (int)((fVar29 - fVar51) * fVar39);
          uVar46 = (uint)fVar26;
          uVar13 = (int)((0xff - iVar44) *
                         ((0xff - iVar45) *
                          (uint)(byte)(&DAT_011dd610)[(uVar36 & 0xff) + (uint)bVar7 + 0x38] +
                         iVar45 * (uint)(byte)(&DAT_011dd610)[(uVar13 & 0xff) + (uint)bVar7 + 0x38])
                        + iVar44 * ((0xff - iVar45) *
                                    (uint)(byte)(&DAT_011dd648)[(uVar36 & 0xff) + (uint)bVar6] +
                                   iVar45 * (uint)(byte)(&DAT_011dd648)
                                                        [(uint)bVar6 + (uVar13 & 0xff)])) >> 0x10;
          uVar36 = (uint)fVar41;
          if (fVar26 < 0.0) {
            uVar12 = uVar46 - 1;
          }
          else {
            uVar12 = uVar46;
            uVar46 = uVar46 + 1;
          }
          bVar16 = SUB41(uVar18 >> 0x1f,0);
          uVar18 = uVar17 | (uint)(fVar25 < 2.0) << 0x1f | (uint)(fVar25 == 2.0) << 0x1e;
          uVar14 = uVar36;
          uVar11 = (uint)((ulonglong)uVar13 * 0xaaaaaaab >> 0x20);
          if (bVar16) {
            uVar14 = uVar36 - 1;
            uVar11 = uVar36;
          }
          if (!bVar16) {
            uVar11 = uVar14 + 1;
          }
          fVar29 = (float)VectorSignedToFloat(uVar12,(byte)(uVar18 >> 0x15) & 3);
          fVar51 = (float)VectorSignedToFloat(uVar14,(byte)(uVar18 >> 0x15) & 3);
          iVar45 = (int)((fVar26 - fVar29) * fVar39);
          iVar47 = (int)((fVar41 - fVar51) * fVar39);
          bVar8 = (byte)(uVar18 >> 0x18);
          fVar29 = fVar40;
          if (!(bool)(bVar8 >> 6 & 1) && (bool)(bVar8 >> 7) == NAN(fVar25)) {
            fVar51 = ABS(fVar41) / fVar25;
            uVar18 = uVar17 | (uint)(fVar51 < 0.5) << 0x1f;
            if (!SUB41(uVar18 >> 0x1f,0)) {
              uVar18 = uVar17 | (uint)(fVar51 < 1.0) << 0x1f | (uint)(fVar51 == 1.0) << 0x1e;
              bVar8 = (byte)(uVar18 >> 0x18);
              fVar29 = DAT_00b8480c;
              if ((bool)(bVar8 >> 6 & 1) || (bool)(bVar8 >> 7) != NAN(fVar51)) {
                fVar29 = (fVar51 - 0.5) + (fVar51 - 0.5);
                fVar29 = 1.0 - (3.0 - (fVar29 + fVar29)) * fVar29 * fVar29;
              }
              fVar29 = fVar29 * fVar40;
            }
          }
          fVar26 = fVar26 + fVar38;
          iVar33 = iVar33 + 1;
          fVar41 = fVar41 + fVar31;
          fVar40 = fVar40 + fVar27;
          fVar51 = (float)VectorSignedToFloat((((uint)(((int)((0xff - iVar43) *
                                                              ((0xff - iVar49) *
                                                               (uint)(byte)(&DAT_011dd610)
                                                                           [(uVar34 & 0xff) +
                                                                            (uint)bVar2 + 0x38] +
                                                              iVar49 * (uint)(byte)(&DAT_011dd610)
                                                                                   [(uVar9 & 0xff) +
                                                                                    (uint)bVar2 +
                                                                                    0x38]) +
                                                             iVar43 * ((0xff - iVar49) *
                                                                       (uint)(byte)(&DAT_011dd648)
                                                                                   [(uVar34 & 0xff)
                                                                                    + (uint)bVar3] +
                                                                      iVar49 * (uint)(byte)(&
                                                  DAT_011dd648)[(uint)bVar3 + (uVar9 & 0xff)])) >>
                                                  0x10) << 1) / 6 +
                                                (uint)(((int)((0xff - iVar48) *
                                                              ((0xff - iVar35) *
                                                               (uint)(byte)(&DAT_011dd610)
                                                                           [(uVar50 & 0xff) +
                                                                            (uint)bVar4 + 0x38] +
                                                              iVar35 * (uint)(byte)(&DAT_011dd610)
                                                                                   [(uVar10 & 0xff)
                                                                                    + (uint)bVar4 +
                                                                                    0x38]) +
                                                             iVar48 * ((0xff - iVar35) *
                                                                       (uint)(byte)(&DAT_011dd648)
                                                                                   [(uVar50 & 0xff)
                                                                                    + (uint)bVar5] +
                                                                      iVar35 * (uint)(byte)(&
                                                  DAT_011dd648)[(uint)bVar5 + (uVar10 & 0xff)])) >>
                                                  0x10) * 3) / 6 + uVar13 / 6) * 7 >> 3) +
                                              ((uint)((int)((0xff - iVar47) *
                                                            ((0xff - iVar45) *
                                                             (uint)(byte)(&DAT_011dd610)
                                                                         [(uVar12 & 0xff) +
                                                                          (uint)(byte)(&DAT_011dd648
                                                                                      )[uVar14 & 
                                                  0xff] + 0x38] +
                                                  iVar45 * (uint)(byte)(&DAT_011dd610)
                                                                       [(uVar46 & 0xff) +
                                                                        (uint)(byte)(&DAT_011dd648)
                                                                                    [uVar14 & 0xff]
                                                                        + 0x38]) +
                                                  iVar47 * ((0xff - iVar45) *
                                                            (uint)(byte)(&DAT_011dd648)
                                                                        [(uVar12 & 0xff) +
                                                                         (uint)(byte)(&DAT_011dd648)
                                                                                     [uVar11 & 0xff]
                                                                        ] +
                                                           iVar45 * (uint)(byte)(&DAT_011dd648)
                                                                                [(uint)(byte)(&
                                                  DAT_011dd648)[uVar11 & 0xff] + (uVar46 & 0xff)]))
                                                  >> 0x10) >> 3),(byte)(uVar18 >> 0x15) & 3);
          fVar25 = fVar25 + fVar57;
          uVar17 = uVar18 & 0xfffffff | (uint)(fVar51 == fVar29) << 0x1e |
                   (uint)(fVar29 <= fVar51) << 0x1d;
          bVar8 = (byte)(uVar17 >> 0x18);
          if (!(bool)(bVar8 >> 5 & 1) || (bool)(bVar8 >> 6)) {
            *puVar15 = *(undefined2 *)(param_9 + 0x28);
          }
          puVar15 = puVar15 + 1;
        } while ((int)(fVar55 - 0.5) + 1 != iVar33);
      }
      fVar19 = fVar19 + 1.0;
      fVar32 = fVar32 + fVar58;
      fVar55 = fVar55 + local_e8;
      uVar13 = uVar17 & 0xfffffff | (uint)(fVar37 < fVar19) << 0x1f;
      uVar17 = uVar13 | (uint)(NAN(fVar37) || NAN(fVar19)) << 0x1c;
      fVar22 = fVar22 + local_90;
      fVar54 = fVar54 + local_e4;
      fVar23 = fVar23 + local_8c;
      fVar21 = fVar21 + local_e0;
    } while ((byte)(uVar13 >> 0x1f) == ((byte)(uVar17 >> 0x1c) & 1));
  }
  if (fVar19 <= fVar20) {
    fVar52 = param_15 - fVar52;
    bVar16 = fVar52 != 0.0;
    fVar54 = (local_dc - local_d8) / fVar52;
    fVar30 = param_15 - fVar30;
    fVar37 = local_ac;
    if (bVar16) {
      fVar37 = (local_c8 - local_b8) / fVar52;
    }
    fVar21 = (local_dc - fVar56) / fVar30;
    local_94 = DAT_00b8480c;
    local_8c = DAT_00b8480c;
    local_ec = DAT_00b8480c;
    if (bVar16) {
      local_94 = (local_c4 - local_b4) / fVar52;
      local_8c = local_dc - fVar56;
      local_ec = fVar37;
    }
    local_90 = local_ec;
    if (bVar16) {
      local_90 = (local_c0 - local_b0) / fVar52;
    }
    if (bVar16) {
      local_8c = (local_bc - local_ac) / fVar52;
    }
    uVar13 = uVar17 & 0xfffffff | (uint)(fVar54 < fVar21) << 0x1f;
    local_7c = DAT_00b84f30;
    local_84 = DAT_00b84f30;
    local_88 = DAT_00b84f30;
    local_80 = DAT_00b84f30;
    if (fVar30 != 0.0) {
      local_88 = (local_c8 - local_a8) / fVar30;
      local_84 = (local_c4 - local_a4) / fVar30;
      local_80 = (local_c0 - local_a0) / fVar30;
      local_7c = (local_bc - local_9c) / fVar30;
    }
    fVar52 = fVar54;
    if (SUB41(uVar13 >> 0x1f,0)) {
      local_98 = local_ec;
      FUN_00b753cc(&local_98,&local_88);
      local_ec = local_98;
      fVar52 = fVar21;
      fVar21 = fVar54;
    }
    param_15 = param_15 - fVar19;
    fVar22 = local_dc - param_15 * fVar21;
    local_dc = local_dc - param_15 * fVar52;
    fVar31 = local_c4 - param_15 * local_94;
    fVar38 = local_c0 - param_15 * local_90;
    fVar57 = local_bc - param_15 * local_8c;
    fVar27 = local_c8 - param_15 * local_ec;
    fVar23 = fVar22 - local_dc;
    uVar13 = uVar13 & 0xfffffff | (uint)(fVar23 == 0.0) << 0x1e;
    fVar37 = DAT_00b84f30;
    fVar56 = DAT_00b84f30;
    fVar30 = DAT_00b84f30;
    fVar54 = DAT_00b84f30;
    if (!SUB41(uVar13 >> 0x1e,0)) {
      fVar37 = ((local_c4 - param_15 * local_84) - fVar31) / fVar23;
      fVar56 = ((local_c8 - param_15 * local_88) - fVar27) / fVar23;
      fVar30 = ((local_c0 - param_15 * local_80) - fVar38) / fVar23;
      fVar54 = ((local_bc - param_15 * local_7c) - fVar57) / fVar23;
    }
    do {
      fVar23 = DAT_00b84f2c;
      iVar33 = (int)(local_dc + 0.5);
      if (iVar33 <= (int)(fVar22 - 0.5)) {
        fVar32 = 1.0 / *(float *)(param_9 + 0x14);
        fVar58 = (float)VectorSignedToFloat(iVar33,(byte)(uVar13 >> 0x15) & 3);
        fVar40 = (float)VectorSignedToFloat((int)fVar19,(byte)(uVar13 >> 0x15) & 3);
        fVar24 = (fVar58 + 0.5) - local_dc;
        fVar40 = fVar40 - *(float *)(param_9 + 0x1c);
        fVar55 = fVar27 + fVar24 * fVar56;
        fVar58 = fVar38 + fVar24 * fVar30;
        fVar39 = fVar57 + fVar24 * fVar54;
        fVar24 = fVar31 + fVar24 * fVar37;
        fVar25 = fVar32 * fVar40;
        fVar26 = fVar32 * 3.0 * fVar40;
        fVar40 = fVar32 * 7.0 * fVar40;
        uVar17 = uVar13 & 0xfffffff | (uint)(fVar26 < 0.0) << 0x1f;
        uVar34 = (int)fVar25 - 1;
        if (0.0 <= fVar25) {
          uVar34 = (int)fVar25;
        }
        fVar28 = *(float *)(param_9 + 0x18);
        fVar29 = (float)VectorSignedToFloat(uVar34,(byte)(uVar17 >> 0x15) & 3);
        uVar13 = uVar13 & 0xfffffff | (uint)(fVar40 < 0.0) << 0x1f;
        iVar43 = (int)((fVar25 - fVar29) * DAT_00b84f2c);
        bVar2 = (&DAT_011dd648)[uVar34 & 0xff];
        bVar3 = (&DAT_011dd648)[uVar34 + 1 & 0xff];
        uVar34 = (int)fVar26 - 1;
        if (!SUB41(uVar17 >> 0x1f,0)) {
          uVar34 = (int)fVar26;
        }
        uVar17 = (int)fVar40 - 1;
        if (!SUB41(uVar13 >> 0x1f,0)) {
          uVar17 = (int)fVar40;
        }
        fVar25 = (float)VectorSignedToFloat(uVar34,(byte)(uVar13 >> 0x15) & 3);
        bVar4 = (&DAT_011dd648)[uVar34 & 0xff];
        bVar5 = (&DAT_011dd648)[uVar34 + 1 & 0xff];
        bVar6 = (&DAT_011dd648)[uVar17 + 1 & 0xff];
        bVar7 = (&DAT_011dd648)[uVar17 & 0xff];
        fVar29 = (float)VectorSignedToFloat(uVar17,(byte)(uVar13 >> 0x15) & 3);
        iVar44 = (int)((fVar26 - fVar25) * DAT_00b84f2c);
        iVar48 = (int)((fVar40 - fVar29) * DAT_00b84f2c);
        puVar15 = (undefined2 *)
                  (*(int *)(param_9 + 0x20) + (*(int *)(param_9 + 0x24) * (int)fVar19 + iVar33) * 2)
        ;
        do {
          fVar25 = (float)VectorSignedToFloat(iVar33,(byte)(uVar13 >> 0x15) & 3);
          fVar25 = fVar25 - fVar28;
          fVar40 = fVar32 * fVar25;
          uVar13 = uVar13 & 0xfffffff;
          uVar17 = uVar13 | (uint)(fVar40 < 0.0) << 0x1f;
          uVar34 = (uint)fVar40;
          if (SUB41(uVar17 >> 0x1f,0)) {
            uVar9 = uVar34;
            uVar34 = uVar34 - 1;
          }
          else {
            uVar9 = uVar34 + 1;
          }
          fVar29 = (float)VectorSignedToFloat(uVar34,(byte)(uVar17 >> 0x15) & 3);
          fVar26 = fVar32 * 3.0 * fVar25;
          iVar49 = (int)((fVar40 - fVar29) * fVar23);
          fVar25 = fVar32 * 7.0 * fVar25;
          uVar50 = (uint)fVar26;
          uVar17 = uVar13 | (uint)(fVar25 < 0.0) << 0x1f;
          if (fVar26 < 0.0) {
            uVar10 = uVar50;
            uVar50 = uVar50 - 1;
          }
          else {
            uVar10 = uVar50 + 1;
          }
          fVar40 = (float)VectorSignedToFloat(uVar50,(byte)(uVar17 >> 0x15) & 3);
          iVar35 = (int)((fVar26 - fVar40) * fVar23);
          uVar36 = (uint)fVar25;
          if (SUB41(uVar17 >> 0x1f,0)) {
            uVar17 = uVar36;
            uVar36 = uVar36 - 1;
          }
          else {
            uVar17 = uVar36 + 1;
          }
          uVar18 = uVar13 | (uint)(fVar24 < 0.0) << 0x1f;
          fVar40 = (float)VectorSignedToFloat(uVar36,(byte)(uVar18 >> 0x15) & 3);
          iVar45 = (int)((fVar25 - fVar40) * fVar23);
          uVar46 = (uint)fVar55;
          uVar17 = (int)((0xff - iVar48) *
                         ((0xff - iVar45) *
                          (uint)(byte)(&DAT_011dd610)[(uVar36 & 0xff) + (uint)bVar7 + 0x38] +
                         iVar45 * (uint)(byte)(&DAT_011dd610)[(uVar17 & 0xff) + (uint)bVar7 + 0x38])
                        + iVar48 * ((0xff - iVar45) *
                                    (uint)(byte)(&DAT_011dd648)[(uVar36 & 0xff) + (uint)bVar6] +
                                   iVar45 * (uint)(byte)(&DAT_011dd648)
                                                        [(uint)bVar6 + (uVar17 & 0xff)])) >> 0x10;
          uVar36 = (uint)fVar24;
          if (fVar55 < 0.0) {
            uVar12 = uVar46 - 1;
          }
          else {
            uVar12 = uVar46;
            uVar46 = uVar46 + 1;
          }
          bVar16 = SUB41(uVar18 >> 0x1f,0);
          uVar18 = uVar13 | (uint)(fVar39 < 2.0) << 0x1f | (uint)(fVar39 == 2.0) << 0x1e;
          uVar14 = uVar36;
          uVar11 = (uint)((ulonglong)uVar17 * 0xaaaaaaab >> 0x20);
          if (bVar16) {
            uVar14 = uVar36 - 1;
            uVar11 = uVar36;
          }
          if (!bVar16) {
            uVar11 = uVar14 + 1;
          }
          fVar40 = (float)VectorSignedToFloat(uVar12,(byte)(uVar18 >> 0x15) & 3);
          fVar25 = (float)VectorSignedToFloat(uVar14,(byte)(uVar18 >> 0x15) & 3);
          iVar45 = (int)((fVar55 - fVar40) * fVar23);
          iVar47 = (int)((fVar24 - fVar25) * fVar23);
          bVar8 = (byte)(uVar18 >> 0x18);
          fVar40 = fVar58;
          if (!(bool)(bVar8 >> 6 & 1) && (bool)(bVar8 >> 7) == NAN(fVar39)) {
            fVar25 = ABS(fVar24) / fVar39;
            uVar18 = uVar13 | (uint)(fVar25 < 0.5) << 0x1f;
            if (!SUB41(uVar18 >> 0x1f,0)) {
              uVar18 = uVar13 | (uint)(fVar25 < 1.0) << 0x1f | (uint)(fVar25 == 1.0) << 0x1e;
              bVar8 = (byte)(uVar18 >> 0x18);
              fVar40 = DAT_00b84f30;
              if ((bool)(bVar8 >> 6 & 1) || (bool)(bVar8 >> 7) != NAN(fVar25)) {
                fVar40 = (fVar25 - 0.5) + (fVar25 - 0.5);
                fVar40 = 1.0 - (3.0 - (fVar40 + fVar40)) * fVar40 * fVar40;
              }
              fVar40 = fVar40 * fVar58;
            }
          }
          fVar55 = fVar55 + fVar56;
          iVar33 = iVar33 + 1;
          fVar24 = fVar24 + fVar37;
          fVar58 = fVar58 + fVar30;
          fVar25 = (float)VectorSignedToFloat((((uint)(((int)((0xff - iVar43) *
                                                              ((0xff - iVar49) *
                                                               (uint)(byte)(&DAT_011dd610)
                                                                           [(uVar34 & 0xff) +
                                                                            (uint)bVar2 + 0x38] +
                                                              iVar49 * (uint)(byte)(&DAT_011dd610)
                                                                                   [(uVar9 & 0xff) +
                                                                                    (uint)bVar2 +
                                                                                    0x38]) +
                                                             iVar43 * ((0xff - iVar49) *
                                                                       (uint)(byte)(&DAT_011dd648)
                                                                                   [(uVar34 & 0xff)
                                                                                    + (uint)bVar3] +
                                                                      iVar49 * (uint)(byte)(&
                                                  DAT_011dd648)[(uint)bVar3 + (uVar9 & 0xff)])) >>
                                                  0x10) << 1) / 6 +
                                                (uint)(((int)((0xff - iVar44) *
                                                              ((0xff - iVar35) *
                                                               (uint)(byte)(&DAT_011dd610)
                                                                           [(uVar50 & 0xff) +
                                                                            (uint)bVar4 + 0x38] +
                                                              iVar35 * (uint)(byte)(&DAT_011dd610)
                                                                                   [(uVar10 & 0xff)
                                                                                    + (uint)bVar4 +
                                                                                    0x38]) +
                                                             iVar44 * ((0xff - iVar35) *
                                                                       (uint)(byte)(&DAT_011dd648)
                                                                                   [(uVar50 & 0xff)
                                                                                    + (uint)bVar5] +
                                                                      iVar35 * (uint)(byte)(&
                                                  DAT_011dd648)[(uint)bVar5 + (uVar10 & 0xff)])) >>
                                                  0x10) * 3) / 6 + uVar17 / 6) * 7 >> 3) +
                                              ((uint)((int)((0xff - iVar47) *
                                                            ((0xff - iVar45) *
                                                             (uint)(byte)(&DAT_011dd610)
                                                                         [(uVar12 & 0xff) +
                                                                          (uint)(byte)(&DAT_011dd648
                                                                                      )[uVar14 & 
                                                  0xff] + 0x38] +
                                                  iVar45 * (uint)(byte)(&DAT_011dd610)
                                                                       [(uVar46 & 0xff) +
                                                                        (uint)(byte)(&DAT_011dd648)
                                                                                    [uVar14 & 0xff]
                                                                        + 0x38]) +
                                                  iVar47 * ((0xff - iVar45) *
                                                            (uint)(byte)(&DAT_011dd648)
                                                                        [(uVar12 & 0xff) +
                                                                         (uint)(byte)(&DAT_011dd648)
                                                                                     [uVar11 & 0xff]
                                                                        ] +
                                                           iVar45 * (uint)(byte)(&DAT_011dd648)
                                                                                [(uint)(byte)(&
                                                  DAT_011dd648)[uVar11 & 0xff] + (uVar46 & 0xff)]))
                                                  >> 0x10) >> 3),(byte)(uVar18 >> 0x15) & 3);
          fVar39 = fVar39 + fVar54;
          uVar13 = uVar18 & 0xfffffff | (uint)(fVar25 == fVar40) << 0x1e |
                   (uint)(fVar40 <= fVar25) << 0x1d;
          bVar8 = (byte)(uVar13 >> 0x18);
          if (!(bool)(bVar8 >> 5 & 1) || (bool)(bVar8 >> 6)) {
            *puVar15 = *(undefined2 *)(param_9 + 0x28);
          }
          puVar15 = puVar15 + 1;
        } while ((int)(fVar22 - 0.5) + 1 != iVar33);
      }
      fVar19 = fVar19 + 1.0;
      local_dc = local_dc + fVar52;
      fVar22 = fVar22 + fVar21;
      uVar13 = uVar13 & 0xfffffff | (uint)(fVar20 < fVar19) << 0x1f;
      fVar27 = fVar27 + local_ec;
      fVar31 = fVar31 + local_94;
      fVar38 = fVar38 + local_90;
      fVar57 = fVar57 + local_8c;
    } while (SUB41(uVar13 >> 0x1f,0) == (NAN(fVar20) || NAN(fVar19)));
  }
  return;
}

