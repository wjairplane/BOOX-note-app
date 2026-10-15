
void FUN_00b8078c(int param_1,int param_2,int param_3,QPointF *param_4,int param_5)

{
  uint uVar1;
  double dVar2;
  int iVar3;
  float *pfVar4;
  float *pfVar5;
  int iVar6;
  byte bVar7;
  int iVar8;
  int iVar9;
  int iVar10;
  int iVar11;
  float *pfVar12;
  uint in_fpscr;
  undefined4 extraout_s2;
  undefined4 extraout_s3;
  float fVar13;
  float fVar14;
  float fVar15;
  float fVar16;
  float fVar17;
  byte local_64;
  
  iVar3 = FUN_00b5f574(param_2);
  if (iVar3 == 0) {
    return;
  }
  pfVar5 = *(float **)(param_2 + 0x10);
  pfVar12 = (float *)((int)pfVar5 + 0xe);
  pfVar4 = (float *)(*(int *)(param_2 + 0x14) * 0xe + (int)pfVar5);
  if (pfVar12 == pfVar4) {
    return;
  }
  while( true ) {
    uVar1 = in_fpscr & 0xfffffff;
    in_fpscr = uVar1 | (uint)(*pfVar5 == *pfVar12) << 0x1e;
    if ((!SUB41(in_fpscr >> 0x1e,0)) ||
       (in_fpscr = uVar1 | (uint)(pfVar12[1] == pfVar5[1]) << 0x1e, !SUB41(in_fpscr >> 0x1e,0)))
    break;
    pfVar12 = (float *)((int)pfVar12 + 0xe);
    if (pfVar4 == pfVar12) {
      return;
    }
  }
  iVar3 = (int)pfVar12 - (int)pfVar5 >> 1;
  iVar8 = iVar3 * -0x49249249;
  if ((int)pfVar12 - (int)pfVar5 < 0) {
    return;
  }
  iVar11 = iVar8 + -1;
  if (param_3 == 1) {
    iVar6 = FUN_00b5f574(param_2);
    iVar10 = iVar6 + -1;
    iVar9 = iVar8;
    if (iVar8 <= iVar6) {
      local_64 = 1;
      iVar9 = iVar11;
    }
    if (iVar6 + iVar3 * 0x49249249 < 0 != SBORROW4(iVar6,iVar8)) goto LAB_00b80a24;
  }
  else {
    iVar3 = FUN_00b5f574(param_2);
    iVar10 = iVar3 + -1;
    if (iVar8 - iVar10 == 0) {
      local_64 = 1;
      iVar9 = iVar11;
    }
    else {
      local_64 = iVar8 - iVar3 == 0;
      iVar9 = iVar10;
    }
  }
LAB_00b80888:
  do {
    fVar13 = DAT_00b80b44;
    fVar14 = DAT_00b80b34;
    iVar3 = *(int *)(param_2 + 0x10) + iVar9 * 0xe;
    iVar6 = *(int *)(param_5 + 0x28);
    fVar17 = (float)VectorUnsignedToFloat((uint)*(ushort *)(iVar3 + 8),(byte)(in_fpscr >> 0x15) & 3)
    ;
    fVar15 = (float)VectorUnsignedToFloat
                              ((uint)*(ushort *)(iVar3 + 10),(byte)(in_fpscr >> 0x15) & 3);
    fVar17 = fVar17 * 0.25;
    in_fpscr = in_fpscr & 0xfffffff;
    uVar1 = in_fpscr | (uint)(fVar17 < 5.0) << 0x1f;
    fVar16 = fVar15 * 0.25 * *(float *)(param_5 + 0x38);
    fVar15 = (float)VectorUnsignedToFloat((uint)*(byte *)(iVar3 + 0xd),(byte)(uVar1 >> 0x15) & 3);
    fVar15 = fVar15 / DAT_00b80b34;
    if (SUB41(uVar1 >> 0x1f,0)) {
      *(float *)(iVar6 + 4) = fVar16;
      uVar1 = in_fpscr | (uint)(fVar15 < fVar13) << 0x1f | (uint)(fVar15 == fVar13) << 0x1e;
      in_fpscr = uVar1 | (uint)(NAN(fVar15) || NAN(fVar13)) << 0x1c;
      bVar7 = (byte)(uVar1 >> 0x18);
      if ((bool)(bVar7 >> 6 & 1) || bVar7 >> 7 != ((byte)(in_fpscr >> 0x1c) & 1)) {
        fVar15 = fVar15 / fVar13;
        fVar14 = (3.0 - (fVar15 + fVar15)) * fVar15 * fVar15 * fVar14;
      }
    }
    else if (fVar17 == DAT_00b80b38 || fVar17 < DAT_00b80b38 != (NAN(fVar17) || NAN(DAT_00b80b38)))
    {
      fVar13 = (fVar17 - 5.0) / DAT_00b80b3c;
      fVar14 = 1.0;
      if (fVar15 == DAT_00b80b44 || fVar15 < DAT_00b80b44 != (NAN(fVar15) || NAN(DAT_00b80b44))) {
        fVar15 = fVar15 / DAT_00b80b44;
        fVar14 = (3.0 - (fVar15 + fVar15)) * fVar15 * fVar15;
      }
      uVar1 = in_fpscr | (uint)(fVar17 < 30.0) << 0x1f | (uint)(fVar17 == 30.0) << 0x1e;
      in_fpscr = uVar1 | (uint)NAN(fVar17) << 0x1c;
      *(float *)(iVar6 + 4) =
           (1.0 - (3.0 - (fVar13 + fVar13)) * fVar13 * fVar13 * DAT_00b80b40) * fVar16;
      bVar7 = (byte)(uVar1 >> 0x18);
      if ((bool)(bVar7 >> 6 & 1) || bVar7 >> 7 != ((byte)(in_fpscr >> 0x1c) & 1)) {
        fVar13 = (fVar17 - 5.0) / 25.0;
        fVar14 = (DAT_00b80b34 - (3.0 - (fVar13 + fVar13)) * fVar13 * fVar13 * DAT_00b80b48) *
                 fVar14;
      }
      else {
LAB_00b80aa8:
        fVar14 = fVar14 * DAT_00b80b4c;
      }
    }
    else {
      uVar1 = in_fpscr | (uint)(fVar15 < DAT_00b80b44) << 0x1f |
              (uint)(fVar15 == DAT_00b80b44) << 0x1e;
      in_fpscr = uVar1 | (uint)(NAN(fVar15) || NAN(DAT_00b80b44)) << 0x1c;
      bVar7 = (byte)(uVar1 >> 0x18);
      *(float *)(iVar6 + 4) = fVar16 * DAT_00b80b44;
      fVar14 = DAT_00b80b4c;
      if ((bool)(bVar7 >> 6 & 1) || bVar7 >> 7 != ((byte)(in_fpscr >> 0x1c) & 1)) {
        fVar15 = fVar15 / fVar13;
        fVar14 = (3.0 - (fVar15 + fVar15)) * fVar15 * fVar15;
        goto LAB_00b80aa8;
      }
    }
    *(float *)(iVar6 + 0x40) = fVar14;
    dVar2 = (double)QTransform::map(param_4);
    if (iVar11 == iVar9) {
      FUN_00b7ed30((float)dVar2,(float)(double)CONCAT44(extraout_s3,extraout_s2),param_1);
      iVar9 = iVar8;
      if (iVar10 < iVar8) break;
      goto LAB_00b80888;
    }
    iVar9 = iVar9 + 1;
    FUN_00b7ef30();
  } while (iVar9 <= iVar10);
  if (param_3 == 0) {
    bVar7 = local_64 & 1;
  }
  else {
    bVar7 = 0;
  }
  if (bVar7 != 0) {
    FUN_00b6b41c(*(undefined4 *)(param_1 + 0xdc),*(undefined4 *)(param_1 + 0xe0),
                 *(undefined4 *)(param_1 + 0xe4),*(undefined4 *)(param_1 + 0xe8),
                 *(undefined4 *)(param_1 + 0xec),*(undefined4 *)(param_1 + 0xf0),
                 *(undefined4 *)(param_1 + 0xf4),*(undefined4 *)(param_1 + 0xf8),param_1,0,
                 *(undefined4 *)(param_1 + 0xd0),*(undefined4 *)(param_1 + 0xd4),
                 *(undefined4 *)(param_1 + 200),*(undefined4 *)(param_1 + 0xcc),
                 *(undefined4 *)(param_1 + 0xd0),*(undefined4 *)(param_1 + 0xd4));
    return;
  }
  if (param_3 != 1) {
    return;
  }
LAB_00b80a24:
  FUN_00b7f218(param_1);
  return;
}

