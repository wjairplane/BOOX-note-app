
void FUN_00b86b14(float param_1,float param_2,float param_3,float param_4,float param_5,
                 float param_6,int *param_7,float param_8,float param_9,float param_10,
                 float param_11,float param_12,float param_13)

{
  bool bVar1;
  byte bVar2;
  uint uVar3;
  uint uVar4;
  uint uVar5;
  uint uVar6;
  ushort *puVar7;
  uint in_fpscr;
  uint uVar8;
  uint uVar9;
  float fVar10;
  float fVar11;
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
  float fVar24;
  float fVar25;
  float fVar26;
  float fVar27;
  float fVar28;
  float fVar29;
  float fVar30;
  float fVar31;
  uint uVar32;
  uint uVar33;
  float fVar34;
  int iVar35;
  int iVar36;
  float fVar37;
  float fVar38;
  float fVar39;
  float fVar40;
  float local_98;
  float local_94;
  
  uVar9 = in_fpscr & 0xfffffff;
  if (param_9 == param_11 || param_9 < param_11 != (NAN(param_9) || NAN(param_11))) {
    fVar38 = param_9;
    fVar14 = param_2;
    fVar13 = param_5;
    fVar39 = param_13;
    fVar15 = param_8;
    fVar16 = param_1;
    local_98 = param_6;
    if (param_13 < param_9) {
      fVar38 = param_13;
      fVar14 = param_6;
      fVar13 = param_1;
      fVar39 = param_9;
      fVar15 = param_12;
      fVar16 = param_5;
      param_12 = param_8;
      local_98 = param_2;
    }
    param_5 = fVar13;
    uVar9 = uVar9 | (uint)(param_11 < fVar39) << 0x1f | (uint)(param_11 == fVar39) << 0x1e;
    uVar8 = uVar9 | (uint)(NAN(param_11) || NAN(fVar39)) << 0x1c;
    bVar2 = (byte)(uVar9 >> 0x18);
    fVar13 = param_5;
    param_1 = param_3;
    param_2 = param_4;
    fVar27 = param_4;
    param_8 = param_10;
    param_9 = param_11;
    param_3 = fVar16;
    local_94 = param_10;
    fVar10 = param_12;
    if (!(bool)(bVar2 >> 6 & 1) && bVar2 >> 7 == ((byte)(uVar8 >> 0x1c) & 1)) goto LAB_00b86ba0;
  }
  else {
    uVar8 = uVar9 | (uint)(param_13 < param_11) << 0x1f;
    fVar38 = param_13;
    fVar39 = param_11;
    fVar14 = param_6;
    fVar13 = param_3;
    fVar27 = param_2;
    fVar15 = param_12;
    fVar16 = param_5;
    local_98 = param_4;
    fVar10 = param_10;
    if ((SUB41(uVar8 >> 0x1f,0)) ||
       (uVar9 = uVar9 | (uint)(param_9 < param_13) << 0x1f | (uint)(param_9 == param_13) << 0x1e,
       uVar8 = uVar9 | (uint)(NAN(param_9) || NAN(param_13)) << 0x1c, bVar2 = (byte)(uVar9 >> 0x18),
       fVar38 = param_11, param_11 = param_9, fVar39 = param_13, fVar14 = param_4, fVar13 = param_5,
       fVar15 = param_10, fVar16 = param_3, local_98 = param_6, local_94 = param_8,
       fVar10 = param_12, !(bool)(bVar2 >> 6 & 1) && bVar2 >> 7 == ((byte)(uVar8 >> 0x1c) & 1)))
    goto LAB_00b86ba0;
  }
  param_9 = fVar39;
  fVar39 = param_11;
  fVar13 = param_1;
  param_1 = param_5;
  fVar27 = local_98;
  param_8 = param_12;
  fVar16 = param_3;
  local_98 = param_2;
  fVar10 = local_94;
LAB_00b86ba0:
  local_94 = fVar10;
  fVar10 = floorf(fVar38);
  fVar28 = 0.5;
  uVar9 = uVar8 & 0xfffffff | (uint)(fVar38 - fVar10 < 0.5) << 0x1f;
  if (!SUB41(uVar9 >> 0x1f,0)) {
    fVar28 = 1.5;
  }
  fVar10 = fVar10 + fVar28;
  fVar28 = floorf(fVar39);
  uVar9 = uVar9 & 0xfffffff | (uint)(fVar39 - fVar28 < 0.5) << 0x1f;
  if (SUB41(uVar9 >> 0x1f,0)) {
    fVar28 = fVar28 - 0.5;
  }
  else {
    fVar28 = fVar28 + 0.5;
  }
  fVar11 = floorf(param_9);
  fVar18 = DAT_00b86fa8;
  uVar9 = uVar9 & 0xfffffff;
  if (param_9 - fVar11 < 0.5) {
    fVar11 = fVar11 - 0.5;
  }
  else {
    fVar11 = fVar11 + 0.5;
  }
  if (fVar10 <= fVar28) {
    fVar24 = fVar39 - fVar38;
    fVar29 = param_9 - fVar38;
    fVar12 = (local_94 - fVar15) / fVar24;
    fVar21 = fVar13 - fVar16;
    if (fVar24 == 0.0) {
      fVar21 = DAT_00b86fa4;
    }
    fVar40 = (param_8 - fVar15) / fVar29;
    fVar22 = fVar21;
    if (fVar24 != 0.0) {
      fVar22 = fVar21 / fVar24;
      fVar21 = (local_98 - fVar14) / fVar24;
    }
    fVar37 = DAT_00b86fa4;
    fVar24 = DAT_00b86fa4;
    if (fVar29 != 0.0) {
      fVar37 = (fVar27 - fVar14) / fVar29;
      fVar24 = (param_1 - fVar16) / fVar29;
    }
    fVar29 = fVar12;
    fVar31 = fVar21;
    fVar19 = fVar22;
    if (fVar12 == fVar40 || fVar12 < fVar40 != (NAN(fVar12) || NAN(fVar40))) {
      fVar29 = fVar40;
      fVar31 = fVar37;
      fVar19 = fVar24;
      fVar40 = fVar12;
      fVar37 = fVar21;
      fVar24 = fVar22;
    }
    fVar22 = fVar28 - fVar38;
    fVar30 = (fVar15 + fVar22 * fVar29) - (fVar15 + fVar22 * fVar40);
    fVar12 = DAT_00b86fa4;
    fVar21 = DAT_00b86fa4;
    if (fVar30 != 0.0) {
      fVar12 = ((fVar14 + fVar22 * fVar31) - (fVar14 + fVar22 * fVar37)) / fVar30;
      fVar21 = ((fVar16 + fVar22 * fVar19) - (fVar16 + fVar22 * fVar24)) / fVar30;
    }
    fVar31 = fVar10 - fVar38;
    fVar30 = fVar15 + fVar31 * fVar40;
    fVar19 = fVar15 + fVar31 * fVar29;
    fVar22 = fVar16 + fVar31 * fVar24;
    fVar31 = fVar14 + fVar31 * fVar37;
    do {
      uVar8 = (uint)(fVar30 + 0.5);
      if ((int)uVar8 <= (int)(fVar19 - 0.5)) {
        fVar25 = (float)VectorSignedToFloat(uVar8,(byte)(uVar9 >> 0x15) & 3);
        uVar6 = (int)(fVar19 - 0.5) + 1;
        fVar25 = (fVar25 + 0.5) - fVar30;
        fVar23 = fVar22 + fVar25 * fVar21;
        fVar25 = fVar31 + fVar25 * fVar12;
        if (uVar8 < uVar6) {
          fVar17 = (float)param_7[4];
          puVar7 = (ushort *)(*param_7 + (param_7[1] * (int)fVar10 + uVar8) * 2);
          uVar4 = param_7[3];
          do {
            fVar26 = fVar17 * fVar25;
            uVar8 = uVar8 + 1;
            uVar32 = (uint)fVar23;
            fVar25 = fVar25 + fVar12;
            uVar9 = uVar9 & 0xfffffff | (uint)(fVar26 < 0.0) << 0x1f;
            uVar33 = (uint)fVar26;
            if (fVar23 < 0.0) {
              uVar3 = uVar32;
              uVar32 = uVar32 - 1;
            }
            else {
              uVar3 = uVar32 + 1;
            }
            if (SUB41(uVar9 >> 0x1f,0)) {
              uVar5 = uVar33;
              uVar33 = uVar33 - 1;
            }
            else {
              uVar5 = uVar33 + 1;
            }
            fVar34 = (float)VectorSignedToFloat(uVar32,(byte)(uVar9 >> 0x15) & 3);
            fVar20 = (float)VectorSignedToFloat(uVar33,(byte)(uVar9 >> 0x15) & 3);
            iVar35 = (int)((fVar23 - fVar34) * fVar18);
            iVar36 = (int)((fVar26 - fVar20) * fVar18);
            fVar23 = fVar23 + fVar21;
            if ((uint)((int)((0xff - iVar36) *
                             ((0xff - iVar35) *
                              (uint)(byte)(&DAT_011dd610)
                                          [(uVar32 & 0xff) +
                                           (uint)(byte)(&DAT_011dd648)[uVar33 & 0xff] + 0x38] +
                             iVar35 * (uint)(byte)(&DAT_011dd610)
                                                  [(uVar3 & 0xff) +
                                                   (uint)(byte)(&DAT_011dd648)[uVar33 & 0xff] + 0x38
                                                  ]) +
                            iVar36 * ((0xff - iVar35) *
                                      (uint)(byte)(&DAT_011dd648)
                                                  [(uVar32 & 0xff) +
                                                   (uint)(byte)(&DAT_011dd648)[uVar5 & 0xff]] +
                                     iVar35 * (uint)(byte)(&DAT_011dd648)
                                                          [(uint)(byte)(&DAT_011dd648)[uVar5 & 0xff]
                                                           + (uVar3 & 0xff)])) >> 0x10) < uVar4) {
              uVar32 = param_7[2];
              *puVar7 = (ushort)(uVar32 >> 8) & 0xf800 | (ushort)(uVar32 >> 5) & 0x7e0 |
                        (ushort)((uVar32 << 0x18) >> 0x1b);
            }
            puVar7 = puVar7 + 1;
          } while (uVar6 != uVar8);
        }
      }
      fVar10 = fVar10 + 1.0;
      fVar30 = fVar30 + fVar40;
      fVar19 = fVar19 + fVar29;
      fVar22 = fVar22 + fVar24;
      uVar9 = uVar9 & 0xfffffff | (uint)(fVar28 < fVar10) << 0x1f;
      fVar31 = fVar31 + fVar37;
    } while (SUB41(uVar9 >> 0x1f,0) == (NAN(fVar28) || NAN(fVar10)));
  }
  fVar28 = DAT_00b86fa8;
  if (fVar10 <= fVar11) {
    fVar39 = param_9 - fVar39;
    fVar38 = param_9 - fVar38;
    bVar1 = fVar39 == 0.0;
    fVar18 = (param_8 - local_94) / fVar39;
    fVar21 = param_8 - local_94;
    if (bVar1) {
      fVar21 = DAT_00b86fa4;
    }
    fVar12 = local_98;
    if (bVar1) {
      fVar12 = fVar21;
    }
    fVar15 = (param_8 - fVar15) / fVar38;
    if (!bVar1) {
      fVar12 = (param_1 - fVar13) / fVar39;
      fVar21 = (fVar27 - local_98) / fVar39;
    }
    fVar13 = DAT_00b86fa4;
    fVar39 = DAT_00b86fa4;
    if (fVar38 != 0.0) {
      fVar13 = (fVar27 - fVar14) / fVar38;
      fVar39 = (param_1 - fVar16) / fVar38;
    }
    fVar38 = fVar39;
    fVar14 = fVar13;
    fVar16 = fVar15;
    if (fVar15 <= fVar18) {
      fVar38 = fVar12;
      fVar14 = fVar21;
      fVar16 = fVar18;
      fVar18 = fVar15;
      fVar12 = fVar39;
      fVar21 = fVar13;
    }
    param_9 = param_9 - fVar10;
    fVar29 = param_8 - param_9 * fVar18;
    param_8 = param_8 - param_9 * fVar16;
    fVar15 = param_1 - fVar38 * param_9;
    fVar22 = fVar27 - fVar14 * param_9;
    fVar24 = fVar29 - param_8;
    uVar9 = uVar9 & 0xfffffff | (uint)(fVar24 == 0.0) << 0x1e;
    fVar39 = DAT_00b86fa4;
    fVar13 = DAT_00b86fa4;
    if (!SUB41(uVar9 >> 0x1e,0)) {
      fVar39 = ((param_1 - param_9 * fVar12) - fVar15) / fVar24;
      fVar13 = ((fVar27 - param_9 * fVar21) - fVar22) / fVar24;
    }
    do {
      uVar8 = (uint)(param_8 + 0.5);
      if ((int)uVar8 <= (int)(fVar29 - 0.5)) {
        fVar27 = (float)VectorSignedToFloat(uVar8,(byte)(uVar9 >> 0x15) & 3);
        uVar6 = (int)(fVar29 - 0.5) + 1;
        fVar27 = (fVar27 + 0.5) - param_8;
        fVar21 = fVar15 + fVar27 * fVar39;
        fVar27 = fVar22 + fVar27 * fVar13;
        if (uVar8 < uVar6) {
          fVar12 = (float)param_7[4];
          puVar7 = (ushort *)(*param_7 + (param_7[1] * (int)fVar10 + uVar8) * 2);
          uVar4 = param_7[3];
          do {
            fVar24 = fVar27 * fVar12;
            uVar8 = uVar8 + 1;
            uVar32 = (uint)fVar21;
            fVar27 = fVar27 + fVar13;
            uVar9 = uVar9 & 0xfffffff | (uint)(fVar24 < 0.0) << 0x1f;
            uVar33 = (uint)fVar24;
            if (fVar21 < 0.0) {
              uVar3 = uVar32;
              uVar32 = uVar32 - 1;
            }
            else {
              uVar3 = uVar32 + 1;
            }
            if (SUB41(uVar9 >> 0x1f,0)) {
              uVar5 = uVar33;
              uVar33 = uVar33 - 1;
            }
            else {
              uVar5 = uVar33 + 1;
            }
            fVar37 = (float)VectorSignedToFloat(uVar32,(byte)(uVar9 >> 0x15) & 3);
            fVar40 = (float)VectorSignedToFloat(uVar33,(byte)(uVar9 >> 0x15) & 3);
            iVar35 = (int)((fVar21 - fVar37) * fVar28);
            iVar36 = (int)((fVar24 - fVar40) * fVar28);
            fVar21 = fVar21 + fVar39;
            if ((uint)((int)((0xff - iVar36) *
                             ((0xff - iVar35) *
                              (uint)(byte)(&DAT_011dd610)
                                          [(uVar32 & 0xff) +
                                           (uint)(byte)(&DAT_011dd648)[uVar33 & 0xff] + 0x38] +
                             iVar35 * (uint)(byte)(&DAT_011dd610)
                                                  [(uVar3 & 0xff) +
                                                   (uint)(byte)(&DAT_011dd648)[uVar33 & 0xff] + 0x38
                                                  ]) +
                            iVar36 * ((0xff - iVar35) *
                                      (uint)(byte)(&DAT_011dd648)
                                                  [(uVar32 & 0xff) +
                                                   (uint)(byte)(&DAT_011dd648)[uVar5 & 0xff]] +
                                     iVar35 * (uint)(byte)(&DAT_011dd648)
                                                          [(uint)(byte)(&DAT_011dd648)[uVar5 & 0xff]
                                                           + (uVar3 & 0xff)])) >> 0x10) < uVar4) {
              uVar32 = param_7[2];
              *puVar7 = (ushort)(uVar32 >> 8) & 0xf800 | (ushort)(uVar32 >> 5) & 0x7e0 |
                        (ushort)((uVar32 << 0x18) >> 0x1b);
            }
            puVar7 = puVar7 + 1;
          } while (uVar6 != uVar8);
        }
      }
      fVar10 = fVar10 + 1.0;
      param_8 = param_8 + fVar16;
      fVar29 = fVar29 + fVar18;
      fVar15 = fVar15 + fVar38;
      uVar9 = uVar9 & 0xfffffff | (uint)(fVar11 < fVar10) << 0x1f;
      fVar22 = fVar22 + fVar14;
    } while (SUB41(uVar9 >> 0x1f,0) == (NAN(fVar11) || NAN(fVar10)));
  }
  return;
}

