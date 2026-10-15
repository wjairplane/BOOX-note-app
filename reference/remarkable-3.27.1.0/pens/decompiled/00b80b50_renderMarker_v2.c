
void FUN_00b80b50(int param_1,int param_2,int param_3,QPointF *param_4,int param_5)

{
  uint uVar1;
  double dVar2;
  float fVar3;
  float fVar4;
  float fVar5;
  int iVar6;
  float *pfVar7;
  byte bVar8;
  float *pfVar9;
  int iVar10;
  int iVar11;
  int iVar12;
  int iVar13;
  float *pfVar14;
  int iVar15;
  uint in_fpscr;
  undefined4 extraout_s2;
  undefined4 extraout_s3;
  float fVar16;
  float fVar17;
  float fVar18;
  byte local_64;
  
  iVar6 = FUN_00b5f574(param_2);
  if (iVar6 == 0) {
    return;
  }
  pfVar7 = *(float **)(param_2 + 0x10);
  pfVar14 = (float *)(*(int *)(param_2 + 0x14) * 0xe + (int)pfVar7);
  pfVar9 = (float *)((int)pfVar7 + 0xe);
  if (pfVar9 == pfVar14) {
    return;
  }
  while( true ) {
    uVar1 = in_fpscr & 0xfffffff;
    in_fpscr = uVar1 | (uint)(*pfVar7 == *pfVar9) << 0x1e;
    if ((!SUB41(in_fpscr >> 0x1e,0)) ||
       (in_fpscr = uVar1 | (uint)(pfVar9[1] == pfVar7[1]) << 0x1e, !SUB41(in_fpscr >> 0x1e,0)))
    break;
    pfVar9 = (float *)((int)pfVar9 + 0xe);
    if (pfVar14 == pfVar9) {
      return;
    }
  }
  iVar6 = (int)pfVar9 - (int)pfVar7 >> 1;
  iVar12 = iVar6 * -0x49249249;
  if ((int)pfVar9 - (int)pfVar7 < 0) {
    return;
  }
  iVar11 = iVar12 + -1;
  if (param_3 == 1) {
    iVar15 = FUN_00b5f574(param_2);
    iVar10 = iVar15 + -1;
    iVar13 = iVar12;
    if (iVar12 <= iVar15) {
      local_64 = 1;
      iVar13 = iVar11;
    }
    fVar3 = DAT_00b80e10;
    fVar4 = DAT_00b80e0c;
    if (iVar15 + iVar6 * 0x49249249 < 0 != SBORROW4(iVar15,iVar12)) goto LAB_00b80d74;
  }
  else {
    iVar6 = FUN_00b5f574(param_2);
    iVar10 = iVar6 + -1;
    fVar3 = DAT_00b80e10;
    fVar4 = DAT_00b80e0c;
    if (iVar12 - iVar10 == 0) {
      local_64 = 1;
      iVar13 = iVar11;
    }
    else {
      local_64 = iVar6 == iVar12;
      iVar13 = iVar10;
    }
  }
  do {
    while( true ) {
      fVar5 = DAT_00b80e18;
      fVar18 = DAT_00b80e14;
      iVar6 = *(int *)(param_2 + 0x10) + iVar13 * 0xe;
      iVar15 = *(int *)(param_5 + 0x2c);
      fVar16 = (float)VectorUnsignedToFloat
                                ((uint)*(ushort *)(iVar6 + 8),(byte)(in_fpscr >> 0x15) & 3);
      fVar17 = (float)VectorUnsignedToFloat
                                ((uint)*(ushort *)(iVar6 + 10),(byte)(in_fpscr >> 0x15) & 3);
      fVar16 = fVar16 * 0.25;
      uVar1 = in_fpscr & 0xfffffff;
      in_fpscr = uVar1 | (uint)(fVar16 < 3.0) << 0x1f;
      *(float *)(iVar15 + 4) = fVar17 * 0.25 * *(float *)(param_5 + 0x38);
      fVar17 = fVar4;
      if ((!SUB41(in_fpscr >> 0x1f,0)) &&
         (uVar1 = uVar1 | (uint)(fVar16 < fVar3) << 0x1f | (uint)(fVar16 == fVar3) << 0x1e,
         in_fpscr = uVar1 | (uint)(NAN(fVar16) || NAN(fVar3)) << 0x1c, bVar8 = (byte)(uVar1 >> 0x18)
         , fVar17 = DAT_00b80e1c,
         (bool)(bVar8 >> 6 & 1) || bVar8 >> 7 != ((byte)(in_fpscr >> 0x1c) & 1))) {
        fVar18 = (fVar16 - 3.0) / fVar18;
        fVar17 = (1.0 - (3.0 - (fVar18 + fVar18)) * fVar18 * fVar18 * fVar5) * fVar4;
      }
      *(float *)(iVar15 + 0x40) = fVar17;
      dVar2 = (double)QTransform::map(param_4);
      if (iVar11 != iVar13) break;
      FUN_00b7ed30((float)dVar2,(float)(double)CONCAT44(extraout_s3,extraout_s2),param_1);
      iVar13 = iVar12;
      if (iVar10 < iVar12) goto LAB_00b80d30;
    }
    iVar13 = iVar13 + 1;
    FUN_00b7ef30();
  } while (iVar13 <= iVar10);
LAB_00b80d30:
  if (param_3 == 0) {
    bVar8 = local_64 & 1;
  }
  else {
    bVar8 = 0;
  }
  if (bVar8 != 0) {
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
LAB_00b80d74:
  FUN_00b7f218(param_1);
  return;
}

