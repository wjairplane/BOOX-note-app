
undefined8 FUN_00b63490(int *param_1,float *param_2,int param_3,int param_4)

{
  byte bVar1;
  float fVar2;
  float fVar3;
  float fVar4;
  float fVar5;
  float fVar6;
  float fVar7;
  float fVar8;
  float __x;
  undefined2 uVar9;
  int iVar10;
  uint in_fpscr;
  uint uVar11;
  uint uVar12;
  uint uVar13;
  float fVar14;
  float fVar15;
  float fVar16;
  undefined8 uVar17;
  undefined8 in_d0;
  float fVar18;
  undefined4 uVar19;
  float fVar20;
  undefined8 unaff_d8;
  float fVar21;
  float fVar22;
  float fVar23;
  float fVar24;
  double dVar25;
  double dVar26;
  double dVar27;
  double dVar28;
  double dVar29;
  undefined1 local_b4;
  undefined1 local_94;
  float local_90;
  float local_8c;
  float local_88;
  float local_84;
  undefined2 local_80;
  undefined2 local_7e;
  undefined1 local_7c;
  undefined1 local_7b;
  float local_70;
  float fStack_6c;
  undefined2 local_68;
  undefined2 uStack_66;
  undefined1 uStack_64;
  undefined1 auStack_63 [3];
  undefined8 local_60;
  undefined4 local_58;
  undefined4 uStack_54;
  char *local_50;
  
  uStack_54 = (undefined4)unaff_d8;
  local_50 = (char *)((ulonglong)unaff_d8 >> 0x20);
  if ((char)param_1[0xe] == '\0') {
    fVar2 = param_2[1];
    fVar3 = param_2[2];
    fVar4 = param_2[3];
    param_1[4] = (int)*param_2;
    param_1[5] = (int)fVar2;
    param_1[6] = (int)fVar3;
    param_1[7] = (int)fVar4;
    param_1[8] = (int)param_2[4];
    fVar4 = param_2[3];
    fVar2 = param_2[1];
    fVar3 = param_2[2];
    param_1[9] = (int)*param_2;
    param_1[10] = (int)fVar2;
    param_1[0xb] = (int)fVar3;
    param_1[0xc] = (int)fVar4;
    param_1[0xd] = (int)param_2[4];
    *(undefined1 *)(param_1 + 0xe) = 1;
  }
  iVar10 = *param_1;
  fVar2 = (float)in_d0;
  if ((10 < iVar10 - 0xdU) || ((0x5cfU >> (iVar10 - 0xdU & 0xff) & 1) == 0)) {
    fVar5 = param_2[1];
    fVar6 = (float)param_1[5];
    fVar7 = *param_2;
    fVar24 = (float)*(double *)(param_1 + 2);
    fVar4 = (float)param_1[4];
    fVar20 = fVar5 - fVar6;
    fVar22 = fVar7 - fVar4;
    fVar3 = (param_2[2] + (float)param_1[6]) * 0.5;
    uVar12 = in_fpscr & 0xfffffff | (uint)(fVar3 < 1.0) << 0x1f | (uint)(fVar3 == 1.0) << 0x1e;
    uVar11 = uVar12 | (uint)NAN(fVar3) << 0x1c;
    bVar1 = (byte)(uVar12 >> 0x18);
    if (!(bool)(bVar1 >> 6 & 1) && bVar1 >> 7 == ((byte)(uVar11 >> 0x1c) & 1)) {
      fVar3 = 1.0;
    }
    fVar14 = atan2f(fVar20,fVar22);
    fVar16 = DAT_00b638c4;
    uVar12 = uVar11 & 0xfffffff | (uint)(fVar14 < 0.0) << 0x1f;
    if (SUB41(uVar12 >> 0x1f,0)) {
      fVar14 = fmodf(fVar14,DAT_00b638c4);
      fVar14 = fVar14 + fVar16;
    }
    else {
      uVar11 = uVar11 & 0xfffffff | (uint)(fVar14 < DAT_00b638c4) << 0x1f |
               (uint)(fVar14 == DAT_00b638c4) << 0x1e;
      uVar12 = uVar11 | (uint)(NAN(fVar14) || NAN(DAT_00b638c4)) << 0x1c;
      bVar1 = (byte)(uVar11 >> 0x18);
      if (!(bool)(bVar1 >> 6 & 1) && bVar1 >> 7 == ((byte)(uVar12 >> 0x1c) & 1)) {
        fVar14 = fmodf(fVar14,DAT_00b638c4);
      }
    }
    fVar21 = fVar6 - (float)param_1[10];
    fVar23 = fVar4 - (float)param_1[9];
    fVar15 = atan2f(fVar21,fVar23);
    fVar16 = DAT_00b63f58;
    uVar11 = uVar12 & 0xfffffff | (uint)(fVar15 < 0.0) << 0x1f;
    if (SUB41(uVar11 >> 0x1f,0)) {
      fVar15 = fmodf(fVar15,DAT_00b63f58);
      fVar15 = fVar15 + fVar16;
    }
    else {
      uVar12 = uVar12 & 0xfffffff | (uint)(fVar15 < DAT_00b638c4) << 0x1f |
               (uint)(fVar15 == DAT_00b638c4) << 0x1e;
      uVar11 = uVar12 | (uint)(NAN(fVar15) || NAN(DAT_00b638c4)) << 0x1c;
      bVar1 = (byte)(uVar12 >> 0x18);
      if (!(bool)(bVar1 >> 6 & 1) && bVar1 >> 7 == ((byte)(uVar11 >> 0x1c) & 1)) {
        fVar15 = fmodf(fVar15,DAT_00b638c4);
      }
    }
    fVar8 = param_2[4];
    __x = param_2[3];
    fVar16 = atan2f(fVar8,__x);
    sincosf(fVar16,&local_8c,&local_90);
    fVar18 = local_90 + fVar7;
    dVar26 = (double)((local_8c + fVar5) - fVar6);
    fVar16 = fVar22;
    if (NAN(fVar22)) {
      fVar16 = -fVar22;
    }
    if (NAN(fVar7)) {
      fVar7 = -fVar7;
    }
    dVar25 = (double)(fVar18 - fVar4);
    fVar8 = SQRT(__x * __x + fVar8 * fVar8);
    if (NAN(fVar4)) {
      fVar4 = -fVar4;
    }
    if (fVar4 <= fVar7) {
      fVar7 = fVar4;
    }
    uVar12 = uVar11 & 0xfffffff | (uint)(fVar16 * DAT_00b638c8 == fVar7) << 0x1e |
             (uint)(fVar7 <= fVar16 * DAT_00b638c8) << 0x1d;
    bVar1 = (byte)(uVar12 >> 0x18);
    if ((bool)(bVar1 >> 5 & 1) && !(bool)(bVar1 >> 6)) {
LAB_00b636f0:
      dVar29 = (double)fVar20;
      dVar28 = (double)fVar22;
      dVar27 = SQRT(dVar29 * dVar29 + dVar28 * dVar28);
      uVar11 = uVar12 & 0xfffffff;
      uVar13 = uVar11 | (uint)(dVar27 < 0.0) << 0x1f;
      uVar12 = uVar13 | (uint)NAN(dVar27) << 0x1c;
      fVar4 = DAT_00b63f5c;
      if (((byte)(uVar13 >> 0x1f) != ((byte)(uVar12 >> 0x1c) & 1)) ||
         (uVar12 = uVar11 | (uint)(dVar27 * DAT_00b638b8 == 0.0) << 0x1e |
                   (uint)(0.0 <= dVar27 * DAT_00b638b8) << 0x1d, bVar1 = (byte)(uVar12 >> 0x18),
         (bool)(bVar1 >> 5 & 1) && !(bool)(bVar1 >> 6))) {
        dVar27 = (dVar29 / dVar27) * dVar26 + (dVar28 / dVar27) * dVar25;
        dVar26 = (dVar26 * dVar26 + dVar25 * dVar25) - dVar27 * dVar27;
        uVar12 = uVar12 & 0xfffffff | (uint)(dVar26 < 0.0) << 0x1f;
        if (!SUB41(uVar12 >> 0x1f,0)) {
          fVar4 = (float)SQRT(dVar26);
        }
      }
    }
    else {
      fVar4 = fVar20;
      if (NAN(fVar20)) {
        fVar4 = -fVar20;
      }
      if (NAN(fVar5)) {
        fVar5 = -fVar5;
      }
      if (NAN(fVar6)) {
        fVar6 = -fVar6;
      }
      if (fVar6 <= fVar5) {
        fVar5 = fVar6;
      }
      uVar12 = uVar11 & 0xfffffff | (uint)(fVar4 * DAT_00b638c8 == fVar5) << 0x1e |
               (uint)(fVar5 <= fVar4 * DAT_00b638c8) << 0x1d;
      bVar1 = (byte)(uVar12 >> 0x18);
      if ((bool)(bVar1 >> 5 & 1) && !(bool)(bVar1 >> 6)) goto LAB_00b636f0;
      fVar4 = (float)SQRT(dVar25 * dVar25 + dVar26 * dVar26);
    }
    fVar4 = powf(fVar4,3.5);
    fVar5 = (SQRT(fVar20 * fVar20 + fVar22 * fVar22) + SQRT(fVar21 * fVar21 + fVar23 * fVar23)) *
            fVar2 * 0.5 * DAT_013a3b08;
    if (param_3 == 0) {
      iVar10 = FUN_00b5f1a8(iVar10);
      if (iVar10 != 0) {
        fVar2 = 1.0 - (fVar5 / fVar2) / DAT_00b638c0;
        uVar11 = uVar12 & 0xfffffff;
        uVar12 = uVar11 | (uint)(fVar2 < 0.5) << 0x1f;
        if (SUB41(uVar12 >> 0x1f,0)) {
          fVar3 = fVar3 * 0.5;
        }
        else {
          uVar11 = uVar11 | (uint)(fVar2 < 1.0) << 0x1f | (uint)(fVar2 == 1.0) << 0x1e;
          uVar12 = uVar11 | (uint)NAN(fVar2) << 0x1c;
          bVar1 = (byte)(uVar11 >> 0x18);
          if ((bool)(bVar1 >> 6 & 1) || bVar1 >> 7 != ((byte)(uVar12 >> 0x1c) & 1)) {
            fVar3 = fVar3 * fVar2;
          }
        }
      }
      iVar10 = *param_1;
    }
    switch(iVar10) {
    case 0:
    case 0xc:
      if (fVar3 < 0.25) {
        fVar3 = 0.25;
      }
      if ((char)param_1[0x22] == '\0') {
        fVar4 = 5.0;
        fVar6 = 10.0;
      }
      else {
        fVar6 = 4.5;
        fVar4 = fVar6;
      }
      fVar20 = powf(fVar3,4.5);
      fVar22 = powf(fVar8,4.0);
      fVar7 = param_2[1];
      fVar2 = *param_2;
      fVar4 = fVar6 * fVar20 + fVar4 * fVar22;
      if (fVar4 < 2.0) {
        fVar4 = 2.0;
      }
      goto LAB_00b63c1c;
    case 1:
      fVar2 = powf(fVar8,4.0);
      fVar4 = (fVar2 - 0.5) * 20.0 * fVar4;
      uVar11 = uVar12 & 0xfffffff | (uint)(fVar4 < 1.5) << 0x1f;
      if (SUB41(uVar11 >> 0x1f,0)) {
        fVar4 = 1.5;
      }
      else {
        uVar11 = uVar12 & 0xfffffff | (uint)(fVar4 < DAT_00b638d4) << 0x1f |
                 (uint)(fVar4 == DAT_00b638d4) << 0x1e;
        bVar1 = (byte)(uVar11 >> 0x18);
        if (!(bool)(bVar1 >> 6 & 1) && (bool)(bVar1 >> 7) == (NAN(fVar4) || NAN(DAT_00b638d4))) {
          fVar4 = DAT_00b638d4;
        }
      }
      fVar7 = param_2[1];
      fVar24 = fVar24 / 1.5;
      fVar2 = *param_2;
      fVar4 = (float)VectorSignedToFloat((int)(fVar4 + fVar3 * 1.5),(byte)(uVar11 >> 0x15) & 3);
      fVar3 = roundf(fVar3 * DAT_00b63f50);
      uVar19 = VectorFloatToUnsigned(fVar3,3);
      local_b4 = (undefined1)uVar19;
      break;
    case 2:
      uVar12 = uVar12 & 0xfffffff;
      uVar11 = uVar12 | (uint)(fVar24 < 1.0) << 0x1f | (uint)(fVar24 == 1.0) << 0x1e;
      uVar13 = uVar11 | (uint)NAN(fVar24) << 0x1c;
      bVar1 = (byte)(uVar11 >> 0x18);
      if ((bool)(bVar1 >> 6 & 1) || bVar1 >> 7 != ((byte)(uVar13 >> 0x1c) & 1)) {
        fVar2 = fVar24 - 1.0;
        uVar11 = uVar12 | (uint)(fVar2 < 0.0) << 0x1f;
        uVar13 = uVar11 | (uint)NAN(fVar2) << 0x1c;
        if ((byte)(uVar11 >> 0x1f) != ((byte)(uVar13 >> 0x1c) & 1)) {
          uVar11 = uVar12 | (uint)(fVar24 < 0.0) << 0x1f;
          uVar13 = uVar11 | (uint)NAN(fVar24) << 0x1c;
          if ((byte)(uVar11 >> 0x1f) == ((byte)(uVar13 >> 0x1c) & 1)) {
            fVar4 = 1.0;
            if (fVar24 < 1.0) {
              fVar4 = fVar24;
            }
            uVar13 = uVar12 | (uint)(-(fVar2 * DAT_00b63f64) == fVar4) << 0x1e |
                     (uint)(fVar4 <= -(fVar2 * DAT_00b63f64)) << 0x1d;
            bVar1 = (byte)(uVar13 >> 0x18);
            if (!(bool)(bVar1 >> 5 & 1) || (bool)(bVar1 >> 6)) goto LAB_00b63ea0;
          }
          goto LAB_00b63c4c;
        }
LAB_00b63ea0:
        uVar12 = uVar13 & 0xfffffff | (uint)(fVar3 < DAT_00b63f60) << 0x1f;
        if (SUB41(uVar12 >> 0x1f,0)) {
          fVar4 = 2.0;
          local_b4 = 0xb3;
        }
        else {
          fVar4 = (float)VectorSignedToFloat((int)(fVar3 * 3.0),(byte)(uVar12 >> 0x15) & 3);
          fVar2 = roundf(fVar3 * DAT_00b63f50);
          uVar19 = VectorFloatToUnsigned(fVar2,3);
          local_b4 = (undefined1)uVar19;
        }
      }
      else {
        fVar24 = fVar24 / DAT_00b638cc;
LAB_00b63c4c:
        fVar2 = roundf(fVar3 * DAT_00b638d0);
        uVar19 = VectorFloatToUnsigned(fVar2,3);
        uVar12 = uVar13 & 0xfffffff | (uint)(fVar3 * 3.0 < 2.0) << 0x1f;
        local_b4 = (undefined1)uVar19;
        if (SUB41(uVar12 >> 0x1f,0)) {
          fVar4 = 2.0;
          fVar2 = *param_2;
          fVar7 = param_2[1];
          break;
        }
        fVar4 = (float)VectorSignedToFloat((int)(fVar3 * 3.0),(byte)(uVar12 >> 0x15) & 3);
      }
      fVar2 = *param_2;
      fVar7 = param_2[1];
      break;
    case 3:
      fVar20 = param_2[4];
      fVar6 = param_2[3];
      fVar2 = atan2f(fVar20,fVar6);
      sincosf(fVar2,&local_8c,&local_90);
      fVar2 = *param_2;
      fVar7 = param_2[1];
      fVar22 = (float)param_1[4];
      fVar16 = (float)param_1[5];
      fVar21 = fVar2 - fVar22;
      dVar25 = (double)((local_90 + fVar2) - fVar22);
      dVar26 = (double)((local_8c + fVar7) - fVar16);
      fVar4 = fVar21;
      if (NAN(fVar21)) {
        fVar4 = -fVar21;
      }
      fVar23 = fVar2;
      if (NAN(fVar2)) {
        fVar23 = -fVar2;
      }
      if (NAN(fVar22)) {
        fVar22 = -fVar22;
      }
      fVar8 = fVar7 - fVar16;
      if (fVar22 <= fVar23) {
        fVar23 = fVar22;
      }
      uVar11 = uVar12 & 0xfffffff | (uint)(fVar4 * DAT_00b638c8 == fVar23) << 0x1e |
               (uint)(fVar23 <= fVar4 * DAT_00b638c8) << 0x1d;
      bVar1 = (byte)(uVar11 >> 0x18);
      if ((bool)(bVar1 >> 5 & 1) && !(bool)(bVar1 >> 6)) {
LAB_00b63d80:
        dVar28 = (double)fVar8;
        dVar27 = (double)fVar21;
        dVar29 = SQRT(dVar28 * dVar28 + dVar27 * dVar27);
        uVar12 = uVar11 & 0xfffffff;
        uVar11 = uVar12 | (uint)(dVar29 < 0.0) << 0x1f;
        fVar4 = DAT_00b63f5c;
        if ((SUB41(uVar11 >> 0x1f,0) != NAN(dVar29)) ||
           (uVar11 = uVar12 | (uint)(dVar29 * DAT_00b63f48 == 0.0) << 0x1e |
                     (uint)(0.0 <= dVar29 * DAT_00b63f48) << 0x1d, bVar1 = (byte)(uVar11 >> 0x18),
           (bool)(bVar1 >> 5 & 1) && !(bool)(bVar1 >> 6))) {
          dVar27 = (dVar28 / dVar29) * dVar26 + (dVar27 / dVar29) * dVar25;
          dVar26 = (dVar26 * dVar26 + dVar25 * dVar25) - dVar27 * dVar27;
          uVar11 = uVar11 & 0xfffffff | (uint)(dVar26 < 0.0) << 0x1f;
          if (!SUB41(uVar11 >> 0x1f,0)) {
            fVar4 = (float)SQRT(dVar26);
          }
        }
      }
      else {
        fVar4 = fVar8;
        if (NAN(fVar8)) {
          fVar4 = -fVar8;
        }
        fVar22 = fVar7;
        if (NAN(fVar7)) {
          fVar22 = -fVar7;
        }
        if (NAN(fVar16)) {
          fVar16 = -fVar16;
        }
        if (fVar16 <= fVar22) {
          fVar22 = fVar16;
        }
        uVar11 = uVar12 & 0xfffffff | (uint)(fVar4 * DAT_00b638c8 == fVar22) << 0x1e |
                 (uint)(fVar22 <= fVar4 * DAT_00b638c8) << 0x1d;
        bVar1 = (byte)(uVar11 >> 0x18);
        if ((bool)(bVar1 >> 5 & 1) && !(bool)(bVar1 >> 6)) goto LAB_00b63d80;
        fVar4 = (float)SQRT(dVar26 * dVar26 + dVar25 * dVar25);
      }
      fVar6 = ABS(fVar6);
      fVar20 = ABS(fVar20);
      if (fVar20 != fVar6 && fVar20 < fVar6 == (NAN(fVar20) || NAN(fVar6))) {
        fVar6 = fVar20;
      }
      uVar12 = uVar11 & 0xfffffff | (uint)(fVar6 < 1.0) << 0x1f;
      if (!SUB41(uVar12 >> 0x1f,0)) {
        fVar6 = 1.0;
      }
      fVar20 = powf(fVar4,3.5);
      fVar6 = powf(fVar6,6.0);
      fVar22 = fVar3 * fVar3 * 4.0;
      if (fVar22 != 4.0 && fVar22 < 4.0 == NAN(fVar22)) {
        fVar22 = 4.0;
      }
      fVar4 = 2.0;
      fVar22 = fVar22 + fVar20 * 10.0 * fVar6 + 2.5;
      if (2.0 <= fVar22) {
        fVar4 = 20.0;
        uVar12 = uVar12 & 0xfffffff | (uint)(fVar22 < 20.0) << 0x1f | (uint)(fVar22 == 20.0) << 0x1e
        ;
        bVar1 = (byte)(uVar12 >> 0x18);
        if ((bool)(bVar1 >> 6 & 1) || (bool)(bVar1 >> 7) != NAN(fVar22)) {
          fVar4 = (float)VectorSignedToFloat((int)fVar22,(byte)(uVar12 >> 0x15) & 3);
        }
      }
LAB_00b63c1c:
      fVar3 = roundf(fVar3 * DAT_00b638d0);
      uVar19 = VectorFloatToUnsigned(fVar3,3);
      local_b4 = (undefined1)uVar19;
      break;
    case 4:
    case 0x11:
      fVar7 = param_2[1];
      fVar4 = 2.0;
      fVar2 = roundf(fVar3 * DAT_00b63f50);
      uVar19 = VectorFloatToUnsigned(fVar2,3);
      fVar2 = *param_2;
      local_b4 = (undefined1)uVar19;
      break;
    case 5:
    case 0x12:
      if (param_3 != 0) {
        uVar9 = 0x78;
        goto LAB_00b638dc;
      }
      fVar7 = param_2[1];
      fVar4 = 30.0;
      fVar2 = roundf(fVar3 * DAT_00b63f50);
      uVar19 = VectorFloatToUnsigned(fVar2,3);
      fVar2 = *param_2;
      local_b4 = (undefined1)uVar19;
      break;
    case 6:
    case 0x16:
      fVar2 = *param_2;
      fVar7 = param_2[1];
      if (param_3 != 0) {
        fVar4 = (float)*(double *)(param_1 + 2) * 10.0;
        goto LAB_00b63c1c;
      }
      fVar4 = 10.0;
      fVar3 = roundf(fVar3 * DAT_00b63f50);
      uVar19 = VectorFloatToUnsigned(fVar3,3);
      local_b4 = (undefined1)uVar19;
      break;
    case 7:
      fVar7 = param_2[1];
      fVar2 = *param_2;
      fVar3 = roundf(fVar3 * DAT_00b63f50);
      uVar19 = VectorFloatToUnsigned(fVar3,3);
      local_b4 = (undefined1)uVar19;
      if (fVar24 == 1.0 || fVar24 < 1.0 != NAN(fVar24)) {
        fVar4 = 3.0;
        break;
      }
      fVar4 = (fVar24 / DAT_00b63f54) * 3.0;
      goto LAB_00b63d20;
    case 8:
    case 10:
    case 0xb:
      uVar9 = 0x10;
LAB_00b638dc:
      fVar7 = param_2[1];
      fVar2 = *param_2;
      fVar3 = roundf(fVar3 * DAT_00b638d0);
      uVar19 = VectorFloatToUnsigned(fVar3,3);
      local_b4 = (undefined1)uVar19;
      goto LAB_00b638fc;
    default:
      return 0;
    }
    fVar4 = fVar4 * fVar24;
    if (fVar4 == 2.0 || fVar4 < 2.0 != NAN(fVar4)) {
      iVar10 = 8;
    }
    uVar9 = (undefined2)iVar10;
    if (fVar4 != 2.0 && fVar4 < 2.0 == NAN(fVar4)) {
LAB_00b63d20:
      fVar3 = roundf(fVar4 * 4.0);
      uVar19 = VectorFloatToUnsigned(fVar3,3);
      uVar9 = (undefined2)uVar19;
    }
LAB_00b638fc:
    local_88 = fVar2;
    local_84 = fVar7;
    fVar2 = roundf(fVar5 * 4.0);
    uVar19 = VectorFloatToUnsigned(fVar2,3);
    local_80 = (undefined2)uVar19;
    local_7e = uVar9;
    fVar2 = roundf(((fVar15 + fVar14) * 0.5 * DAT_00b638d0) / DAT_00b638c4);
    uVar19 = VectorFloatToUnsigned(fVar2,3);
    local_7c = (undefined1)uVar19;
    local_7b = local_b4;
    FUN_00b6072c(param_1 + 0x10,&local_88);
    param_1[9] = param_1[4];
    param_1[10] = param_1[5];
    param_1[0xb] = param_1[6];
    param_1[0xc] = param_1[7];
    param_1[0xd] = param_1[8];
    fVar2 = param_2[1];
    fVar3 = param_2[2];
    fVar4 = param_2[3];
    param_1[4] = (int)*param_2;
    param_1[5] = (int)fVar2;
    param_1[6] = (int)fVar3;
    param_1[7] = (int)fVar4;
    param_1[8] = (int)param_2[4];
    uVar17 = FUN_00b62c58(param_1);
    return uVar17;
  }
  fVar6 = param_2[3];
  fVar3 = tanf(fVar6);
  fVar20 = param_2[4];
  fVar4 = tanf(fVar20);
  fVar3 = atanf(SQRT(fVar4 * fVar4 + fVar3 * fVar3));
  fVar4 = param_2[2];
  uVar12 = in_fpscr & 0xfffffff | (uint)(fVar3 < 1.0) << 0x1f | (uint)(fVar3 == 1.0) << 0x1e;
  uVar11 = uVar12 | (uint)NAN(fVar3) << 0x1c;
  fVar5 = param_2[1];
  bVar1 = (byte)(uVar12 >> 0x18);
  fVar7 = *param_2;
  if (!(bool)(bVar1 >> 6 & 1) && bVar1 >> 7 == ((byte)(uVar11 >> 0x1c) & 1)) {
    fVar3 = 1.0;
  }
  fVar22 = fVar5 - (float)param_1[5];
  fVar24 = fVar7 - (float)param_1[4];
  fVar16 = fVar2 * SQRT(fVar22 * fVar22 + fVar24 * fVar24) * DAT_013a3b08;
  fVar22 = atan2f(fVar22,fVar24);
  fVar2 = DAT_00b6328c;
  uVar12 = uVar11 & 0xfffffff | (uint)(fVar22 < 0.0) << 0x1f;
  if (SUB41(uVar12 >> 0x1f,0)) {
    fVar22 = fmodf(fVar22,DAT_00b6328c);
    fVar22 = fVar22 + fVar2;
  }
  else {
    uVar11 = uVar11 & 0xfffffff | (uint)(fVar22 < DAT_00b6328c) << 0x1f |
             (uint)(fVar22 == DAT_00b6328c) << 0x1e;
    uVar12 = uVar11 | (uint)(NAN(fVar22) || NAN(DAT_00b6328c)) << 0x1c;
    bVar1 = (byte)(uVar11 >> 0x18);
    if (!(bool)(bVar1 >> 6 & 1) && bVar1 >> 7 == ((byte)(uVar12 >> 0x1c) & 1)) {
      fVar22 = fmodf(fVar22,DAT_00b6328c);
    }
  }
  fVar2 = DAT_00b63488;
  switch(*param_1) {
  case 0xd:
    fVar2 = (float)*(double *)(param_1 + 2);
    if (fVar2 != 1.0 && fVar2 < 1.0 == NAN(fVar2)) {
      fVar2 = fVar2 / DAT_00b63290;
    }
    fVar2 = fVar2 * 4.0;
    if (fVar4 < 0.0) {
      local_94 = 0xb3;
      goto LAB_00b62f40;
    }
    if (fVar4 != 1.0 && fVar4 < 1.0 == NAN(fVar4)) {
      local_94 = 0xff;
      goto LAB_00b62f40;
    }
    fVar6 = (DAT_00b63294 + (3.0 - (fVar4 + fVar4)) * fVar4 * fVar4 * DAT_00b632c4) * DAT_00b632d4;
    break;
  case 0xe:
    uVar11 = uVar12 & 0xfffffff | (uint)(fVar3 < DAT_00b63298) << 0x1f;
    fVar2 = DAT_00b632dc;
    if (!SUB41(uVar11 >> 0x1f,0)) {
      uVar12 = uVar12 & 0xfffffff | (uint)(fVar3 < DAT_00b6329c) << 0x1f |
               (uint)(fVar3 == DAT_00b6329c) << 0x1e;
      uVar11 = uVar12 | (uint)(NAN(fVar3) || NAN(DAT_00b6329c)) << 0x1c;
      bVar1 = (byte)(uVar12 >> 0x18);
      if ((bool)(bVar1 >> 6 & 1) || bVar1 >> 7 != ((byte)(uVar11 >> 0x1c) & 1)) {
        fVar2 = (fVar3 - DAT_00b63298) / DAT_00b632a0;
      }
      else {
        fVar2 = 1.0;
      }
    }
    if ((char)param_1[0x22] == '\0') {
      fVar2 = fVar2 * fVar2;
    }
    else {
      fVar2 = powf(fVar2,4.0);
    }
    if (param_1[0x15] != 0) {
      fVar3 = (float)VectorUnsignedToFloat
                               ((uint)*(byte *)(param_1[0x15] * 0xe + param_1[0x14] + -1),
                                (byte)(uVar11 >> 0x15) & 3);
      fVar4 = fVar4 * DAT_00b632a4 + (fVar3 / DAT_00b632d4) * DAT_00b632a8;
    }
    fVar6 = fVar4 * DAT_00b632d4;
    fVar2 = (fVar4 + 2.0 + fVar2 * 15.0) * (float)*(double *)(param_1 + 2);
    break;
  case 0xf:
    fVar3 = (float)*(double *)(param_1 + 2);
    fVar6 = fVar4 * DAT_00b632d4;
    if (fVar3 != 1.0 && fVar3 < 1.0 == NAN(fVar3)) {
      fVar3 = fVar3 / DAT_00b63290;
    }
    fVar2 = fVar4 * 3.0;
    if (fVar4 * 3.0 < 2.0) {
      fVar2 = 2.0;
    }
    fVar2 = fVar2 * fVar3;
    break;
  case 0x10:
    fVar6 = fVar4 * DAT_00b632d4;
    fVar2 = ((fVar4 * 0.5 + 0.5) * fVar3 * fVar3 * 10.0 + 2.5) * (float)*(double *)(param_1 + 2);
    break;
  default:
    local_60 = DAT_00b63480;
    local_58 = 0;
    uStack_54 = 0;
    local_50 = "default";
    QMessageLogger::warning((char *)&local_60,"bad tool type!");
    fVar5 = param_2[1];
    fVar7 = *param_2;
    fVar3 = roundf(fVar4 * DAT_00b6348c);
    uVar19 = VectorFloatToUnsigned(fVar3,3);
    local_94 = (undefined1)uVar19;
    goto LAB_00b62f40;
  case 0x13:
  case 0x14:
    fVar6 = fVar4 * DAT_00b632d4;
    fVar2 = (float)*(double *)(param_1 + 2) + (float)*(double *)(param_1 + 2);
    break;
  case 0x15:
    fVar2 = DAT_00b632b0;
    if (param_4 != 0) {
      fVar2 = DAT_00b632ac;
    }
    fVar24 = ((fVar2 + (float)((ulonglong)in_d0 >> 0x20)) * DAT_00b632b4) / DAT_00b632b8;
    fVar2 = sinf(fVar6);
    fVar3 = sinf(fVar20);
    fVar2 = atan2f(fVar3,fVar2);
    iVar10 = param_1[0x15];
    if (fVar2 < 0.0) {
      fVar2 = fVar2 + DAT_00b6328c;
    }
    fVar2 = fVar22 - fVar2;
    if (fVar2 < 0.0) {
      fVar2 = fVar2 + DAT_00b6328c;
    }
    fVar2 = fVar2 - (DAT_00b632c0 - fVar24);
    if (fVar2 < 0.0) {
      fVar2 = fVar2 + DAT_00b6328c;
    }
    if (fVar2 != DAT_00b632b4 && fVar2 < DAT_00b632b4 == (NAN(fVar2) || NAN(DAT_00b632b4))) {
      fVar2 = fVar2 - DAT_00b6328c;
    }
    fVar2 = (DAT_00b632bc - ABS(fVar2)) / DAT_00b632bc;
    if (fVar2 == DAT_00b632dc || fVar2 < DAT_00b632dc != (NAN(fVar2) || NAN(DAT_00b632dc))) {
      fVar2 = DAT_00b632dc;
    }
    fVar3 = (fVar2 * fVar4 * 4.5 + 1.0) * (float)*(double *)(param_1 + 2);
    uVar12 = uVar12 & 0xfffffff | (uint)(fVar3 < DAT_013a3b0c) << 0x1f |
             (uint)(fVar3 == DAT_013a3b0c) << 0x1e;
    uVar11 = uVar12 | (uint)(NAN(fVar3) || NAN(DAT_013a3b0c)) << 0x1c;
    bVar1 = (byte)(uVar12 >> 0x18);
    fVar2 = DAT_013a3b0c;
    if (!(bool)(bVar1 >> 6 & 1) && bVar1 >> 7 == ((byte)(uVar11 >> 0x1c) & 1)) {
      fVar2 = fVar3;
    }
    fVar3 = roundf(fVar4 * DAT_00b632d4);
    uVar19 = VectorFloatToUnsigned(fVar3,3);
    local_94 = (undefined1)uVar19;
    if (iVar10 != 0) {
      fVar3 = (float)VectorUnsignedToFloat
                               ((uint)*(ushort *)(iVar10 * 0xe + param_1[0x14] + -4),
                                (byte)(uVar11 >> 0x15) & 3);
      fVar2 = fVar2 * 0.25 + fVar3 * 0.25 * 0.75;
    }
    goto LAB_00b62f40;
  case 0x17:
    fVar3 = DAT_00b632d8;
    if (DAT_00b632cc <= fVar4) {
      if (fVar4 == DAT_00b632c4 || fVar4 < DAT_00b632c4 != (NAN(fVar4) || NAN(DAT_00b632c4))) {
        fVar2 = (fVar4 - DAT_00b632cc) / DAT_00b632c8;
        fVar3 = fVar2 + (1.0 - fVar2) * DAT_00b632d8;
      }
      else {
        fVar3 = 1.0;
      }
    }
    fVar2 = (float)FUN_00b5f7fc(0x3f800000,param_1 + 0x10);
    fVar2 = fVar2 * fVar3;
    if (param_1[0x15] == 0) {
      fVar5 = param_2[1];
      fVar7 = *param_2;
      fVar3 = roundf(fVar4 * DAT_00b632d4);
      uVar19 = VectorFloatToUnsigned(fVar3,3);
      local_94 = (undefined1)uVar19;
    }
    else {
      fVar5 = param_2[1];
      fVar3 = (float)VectorFloatToUnsignedFixed
                               ((uint)*(ushort *)(param_1[0x15] * 0xe + param_1[0x14] + -6),0x20,2);
      fVar7 = *param_2;
      fVar16 = fVar16 * DAT_00b632cc + fVar3 * DAT_00b632d0;
      fVar3 = roundf(fVar4 * DAT_00b632d4);
      uVar19 = VectorFloatToUnsigned(fVar3,3);
      local_94 = (undefined1)uVar19;
    }
    goto LAB_00b62f40;
  }
  fVar3 = roundf(fVar6);
  uVar19 = VectorFloatToUnsigned(fVar3,3);
  local_94 = (undefined1)uVar19;
LAB_00b62f40:
  _local_70 = CONCAT44(fVar5,fVar7);
  fVar3 = roundf(fVar16 * 4.0);
  uVar19 = VectorFloatToUnsigned(fVar3,3);
  _local_68 = CONCAT62(_uStack_66,(short)uVar19);
  fVar2 = roundf(fVar2 * 4.0);
  uVar19 = VectorFloatToUnsigned(fVar2,3);
  _local_68 = CONCAT22((short)uVar19,local_68);
  fVar2 = roundf((fVar22 * DAT_00b632d4) / DAT_00b6328c);
  uVar19 = VectorFloatToUnsigned(fVar2,3);
  _local_68 = CONCAT35(CONCAT21(auStack_63._1_2_,local_94),CONCAT14((char)uVar19,_local_68));
  FUN_00b6072c(param_1 + 0x10,&local_70);
  param_1[9] = param_1[4];
  param_1[10] = param_1[5];
  param_1[0xb] = param_1[6];
  param_1[0xc] = param_1[7];
  param_1[0xd] = param_1[8];
  fVar2 = param_2[1];
  fVar3 = param_2[2];
  fVar4 = param_2[3];
  param_1[4] = (int)*param_2;
  param_1[5] = (int)fVar2;
  param_1[6] = (int)fVar3;
  param_1[7] = (int)fVar4;
  param_1[8] = (int)param_2[4];
  uVar17 = FUN_00b62c58(param_1);
  return uVar17;
}

