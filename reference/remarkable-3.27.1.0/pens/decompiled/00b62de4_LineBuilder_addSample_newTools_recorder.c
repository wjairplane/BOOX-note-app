
void FUN_00b62de4(float param_1,float param_2,undefined4 *param_3,float *param_4,int param_5)

{
  byte bVar1;
  float fVar2;
  int iVar3;
  float fVar4;
  float fVar5;
  float fVar6;
  uint in_fpscr;
  uint uVar7;
  uint uVar8;
  float fVar9;
  float fVar10;
  float fVar11;
  float fVar12;
  undefined4 uVar13;
  float fVar14;
  undefined1 uStack_94;
  float fStack_70;
  float fStack_6c;
  undefined2 uStack_68;
  undefined2 uStack_66;
  undefined1 uStack_64;
  undefined1 uStack_63;
  undefined8 uStack_60;
  undefined8 uStack_58;
  char *pcStack_50;
  
  fVar5 = param_4[3];
  fVar9 = tanf(fVar5);
  fVar6 = param_4[4];
  fVar10 = tanf(fVar6);
  fVar9 = atanf(SQRT(fVar10 * fVar10 + fVar9 * fVar9));
  fVar10 = param_4[2];
  uVar8 = in_fpscr & 0xfffffff | (uint)(fVar9 < 1.0) << 0x1f | (uint)(fVar9 == 1.0) << 0x1e;
  uVar7 = uVar8 | (uint)NAN(fVar9) << 0x1c;
  fVar2 = param_4[1];
  bVar1 = (byte)(uVar8 >> 0x18);
  fVar4 = *param_4;
  if (!(bool)(bVar1 >> 6 & 1) && bVar1 >> 7 == ((byte)(uVar7 >> 0x1c) & 1)) {
    fVar9 = 1.0;
  }
  fVar11 = fVar2 - (float)param_3[5];
  fVar12 = fVar4 - (float)param_3[4];
  fVar14 = param_1 * SQRT(fVar11 * fVar11 + fVar12 * fVar12) * DAT_013a3b08;
  fVar12 = atan2f(fVar11,fVar12);
  fVar11 = DAT_00b6328c;
  uVar8 = uVar7 & 0xfffffff | (uint)(fVar12 < 0.0) << 0x1f;
  if (SUB41(uVar8 >> 0x1f,0)) {
    fVar12 = fmodf(fVar12,DAT_00b6328c);
    fVar12 = fVar12 + fVar11;
  }
  else {
    uVar7 = uVar7 & 0xfffffff | (uint)(fVar12 < DAT_00b6328c) << 0x1f |
            (uint)(fVar12 == DAT_00b6328c) << 0x1e;
    uVar8 = uVar7 | (uint)(NAN(fVar12) || NAN(DAT_00b6328c)) << 0x1c;
    bVar1 = (byte)(uVar7 >> 0x18);
    if (!(bool)(bVar1 >> 6 & 1) && bVar1 >> 7 == ((byte)(uVar8 >> 0x1c) & 1)) {
      fVar12 = fmodf(fVar12,DAT_00b6328c);
    }
  }
  fVar11 = DAT_00b63488;
  switch(*param_3) {
  case 0xd:
    fVar11 = (float)*(double *)(param_3 + 2);
    if (fVar11 != 1.0 && fVar11 < 1.0 == NAN(fVar11)) {
      fVar11 = fVar11 / DAT_00b63290;
    }
    fVar11 = fVar11 * 4.0;
    if (fVar10 < 0.0) {
      uStack_94 = 0xb3;
      goto LAB_00b62f40;
    }
    if (fVar10 != 1.0 && fVar10 < 1.0 == NAN(fVar10)) {
      uStack_94 = 0xff;
      goto LAB_00b62f40;
    }
    fVar5 = (DAT_00b63294 + (3.0 - (fVar10 + fVar10)) * fVar10 * fVar10 * DAT_00b632c4) *
            DAT_00b632d4;
    break;
  case 0xe:
    uVar7 = uVar8 & 0xfffffff | (uint)(fVar9 < DAT_00b63298) << 0x1f;
    fVar6 = DAT_00b632dc;
    if (!SUB41(uVar7 >> 0x1f,0)) {
      uVar8 = uVar8 & 0xfffffff | (uint)(fVar9 < DAT_00b6329c) << 0x1f |
              (uint)(fVar9 == DAT_00b6329c) << 0x1e;
      uVar7 = uVar8 | (uint)(NAN(fVar9) || NAN(DAT_00b6329c)) << 0x1c;
      bVar1 = (byte)(uVar8 >> 0x18);
      if ((bool)(bVar1 >> 6 & 1) || bVar1 >> 7 != ((byte)(uVar7 >> 0x1c) & 1)) {
        fVar6 = (fVar9 - DAT_00b63298) / DAT_00b632a0;
      }
      else {
        fVar6 = 1.0;
      }
    }
    if (*(char *)(param_3 + 0x22) == '\0') {
      fVar6 = fVar6 * fVar6;
    }
    else {
      fVar6 = powf(fVar6,4.0);
    }
    if (param_3[0x15] != 0) {
      fVar9 = (float)VectorUnsignedToFloat
                               ((uint)*(byte *)(param_3[0x15] * 0xe + param_3[0x14] + -1),
                                (byte)(uVar7 >> 0x15) & 3);
      fVar10 = fVar10 * DAT_00b632a4 + (fVar9 / DAT_00b632d4) * DAT_00b632a8;
    }
    fVar5 = fVar10 * DAT_00b632d4;
    fVar11 = (fVar10 + 2.0 + fVar6 * 15.0) * (float)*(double *)(param_3 + 2);
    break;
  case 0xf:
    fVar9 = (float)*(double *)(param_3 + 2);
    fVar5 = fVar10 * DAT_00b632d4;
    if (fVar9 != 1.0 && fVar9 < 1.0 == NAN(fVar9)) {
      fVar9 = fVar9 / DAT_00b63290;
    }
    fVar11 = fVar10 * 3.0;
    if (fVar10 * 3.0 < 2.0) {
      fVar11 = 2.0;
    }
    fVar11 = fVar11 * fVar9;
    break;
  case 0x10:
    fVar5 = fVar10 * DAT_00b632d4;
    fVar11 = ((fVar10 * 0.5 + 0.5) * fVar9 * fVar9 * 10.0 + 2.5) * (float)*(double *)(param_3 + 2);
    break;
  default:
    uStack_60 = DAT_00b63480;
    uStack_58 = 0;
    pcStack_50 = "default";
    QMessageLogger::warning((char *)&uStack_60,"bad tool type!");
    fVar2 = param_4[1];
    fVar4 = *param_4;
    fVar9 = roundf(fVar10 * DAT_00b6348c);
    uVar13 = VectorFloatToUnsigned(fVar9,3);
    uStack_94 = (undefined1)uVar13;
    goto LAB_00b62f40;
  case 0x13:
  case 0x14:
    fVar5 = fVar10 * DAT_00b632d4;
    fVar11 = (float)*(double *)(param_3 + 2) + (float)*(double *)(param_3 + 2);
    break;
  case 0x15:
    fVar9 = DAT_00b632b0;
    if (param_5 != 0) {
      fVar9 = DAT_00b632ac;
    }
    fVar11 = ((fVar9 + param_2) * DAT_00b632b4) / DAT_00b632b8;
    fVar9 = sinf(fVar5);
    fVar5 = sinf(fVar6);
    fVar9 = atan2f(fVar5,fVar9);
    iVar3 = param_3[0x15];
    if (fVar9 < 0.0) {
      fVar9 = fVar9 + DAT_00b6328c;
    }
    fVar9 = fVar12 - fVar9;
    if (fVar9 < 0.0) {
      fVar9 = fVar9 + DAT_00b6328c;
    }
    fVar9 = fVar9 - (DAT_00b632c0 - fVar11);
    if (fVar9 < 0.0) {
      fVar9 = fVar9 + DAT_00b6328c;
    }
    if (fVar9 != DAT_00b632b4 && fVar9 < DAT_00b632b4 == (NAN(fVar9) || NAN(DAT_00b632b4))) {
      fVar9 = fVar9 - DAT_00b6328c;
    }
    fVar9 = (DAT_00b632bc - ABS(fVar9)) / DAT_00b632bc;
    if (fVar9 == DAT_00b632dc || fVar9 < DAT_00b632dc != (NAN(fVar9) || NAN(DAT_00b632dc))) {
      fVar9 = DAT_00b632dc;
    }
    fVar9 = (fVar9 * fVar10 * 4.5 + 1.0) * (float)*(double *)(param_3 + 2);
    uVar8 = uVar8 & 0xfffffff | (uint)(fVar9 < DAT_013a3b0c) << 0x1f |
            (uint)(fVar9 == DAT_013a3b0c) << 0x1e;
    uVar7 = uVar8 | (uint)(NAN(fVar9) || NAN(DAT_013a3b0c)) << 0x1c;
    bVar1 = (byte)(uVar8 >> 0x18);
    fVar11 = DAT_013a3b0c;
    if (!(bool)(bVar1 >> 6 & 1) && bVar1 >> 7 == ((byte)(uVar7 >> 0x1c) & 1)) {
      fVar11 = fVar9;
    }
    fVar9 = roundf(fVar10 * DAT_00b632d4);
    uVar13 = VectorFloatToUnsigned(fVar9,3);
    uStack_94 = (undefined1)uVar13;
    if (iVar3 != 0) {
      fVar9 = (float)VectorUnsignedToFloat
                               ((uint)*(ushort *)(iVar3 * 0xe + param_3[0x14] + -4),
                                (byte)(uVar7 >> 0x15) & 3);
      fVar11 = fVar11 * 0.25 + fVar9 * 0.25 * 0.75;
    }
    goto LAB_00b62f40;
  case 0x17:
    fVar9 = DAT_00b632d8;
    if (DAT_00b632cc <= fVar10) {
      if (fVar10 == DAT_00b632c4 || fVar10 < DAT_00b632c4 != (NAN(fVar10) || NAN(DAT_00b632c4))) {
        fVar9 = (fVar10 - DAT_00b632cc) / DAT_00b632c8;
        fVar9 = fVar9 + (1.0 - fVar9) * DAT_00b632d8;
      }
      else {
        fVar9 = 1.0;
      }
    }
    fVar11 = (float)FUN_00b5f7fc(0x3f800000,param_3 + 0x10);
    fVar11 = fVar11 * fVar9;
    if (param_3[0x15] == 0) {
      fVar2 = param_4[1];
      fVar4 = *param_4;
      fVar9 = roundf(fVar10 * DAT_00b632d4);
      uVar13 = VectorFloatToUnsigned(fVar9,3);
      uStack_94 = (undefined1)uVar13;
    }
    else {
      fVar2 = param_4[1];
      fVar9 = (float)VectorFloatToUnsignedFixed
                               ((uint)*(ushort *)(param_3[0x15] * 0xe + param_3[0x14] + -6),0x20,2);
      fVar4 = *param_4;
      fVar14 = fVar14 * DAT_00b632cc + fVar9 * DAT_00b632d0;
      fVar9 = roundf(fVar10 * DAT_00b632d4);
      uVar13 = VectorFloatToUnsigned(fVar9,3);
      uStack_94 = (undefined1)uVar13;
    }
    goto LAB_00b62f40;
  }
  fVar9 = roundf(fVar5);
  uVar13 = VectorFloatToUnsigned(fVar9,3);
  uStack_94 = (undefined1)uVar13;
LAB_00b62f40:
  fStack_70 = fVar4;
  fStack_6c = fVar2;
  fVar9 = roundf(fVar14 * 4.0);
  uVar13 = VectorFloatToUnsigned(fVar9,3);
  uStack_68 = (undefined2)uVar13;
  fVar9 = roundf(fVar11 * 4.0);
  uVar13 = VectorFloatToUnsigned(fVar9,3);
  uStack_66 = (undefined2)uVar13;
  fVar9 = roundf((fVar12 * DAT_00b632d4) / DAT_00b6328c);
  uVar13 = VectorFloatToUnsigned(fVar9,3);
  uStack_64 = (undefined1)uVar13;
  uStack_63 = uStack_94;
  FUN_00b6072c(param_3 + 0x10,&fStack_70);
  param_3[9] = param_3[4];
  param_3[10] = param_3[5];
  param_3[0xb] = param_3[6];
  param_3[0xc] = param_3[7];
  param_3[0xd] = param_3[8];
  fVar9 = param_4[1];
  fVar10 = param_4[2];
  fVar2 = param_4[3];
  param_3[4] = *param_4;
  param_3[5] = fVar9;
  param_3[6] = fVar10;
  param_3[7] = fVar2;
  param_3[8] = param_4[4];
  FUN_00b62c58(param_3);
  return;
}

