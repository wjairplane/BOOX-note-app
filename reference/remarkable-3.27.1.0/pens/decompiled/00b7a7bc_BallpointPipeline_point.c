
void FUN_00b7a7bc(undefined4 param_1,undefined4 param_2,float param_3,int param_4,undefined4 param_5
                 ,undefined4 param_6,uint param_7,uint param_8)

{
  byte bVar1;
  float fVar2;
  int iVar3;
  bool bVar4;
  uint in_fpscr;
  uint uVar5;
  float fVar6;
  float fVar7;
  float fVar8;
  undefined4 uVar9;
  
  fVar2 = DAT_00b7a984;
  fVar8 = (float)VectorUnsignedToFloat(param_8 >> 8 & 0xff,(byte)(in_fpscr >> 0x15) & 3);
  fVar8 = fVar8 / DAT_00b7a974;
  if (fVar8 == DAT_00b7a978 || fVar8 < DAT_00b7a978 != (NAN(fVar8) || NAN(DAT_00b7a978))) {
    fVar8 = fVar8 / DAT_00b7a978;
    fVar8 = (3.0 - (fVar8 + fVar8)) * fVar8 * fVar8 * 0.5 + 0.5;
  }
  else {
    fVar8 = 1.0;
  }
  fVar7 = (float)VectorFloatToUnsignedFixed(param_7 & 0xffff,0x20,2);
  uVar5 = in_fpscr & 0xfffffff | (uint)(fVar7 < 5.0) << 0x1f;
  fVar6 = DAT_00b7a974;
  if ((!SUB41(uVar5 >> 0x1f,0)) &&
     (uVar5 = in_fpscr & 0xfffffff | (uint)(fVar7 < 30.0) << 0x1f | (uint)(fVar7 == 30.0) << 0x1e,
     bVar1 = (byte)(uVar5 >> 0x18), fVar6 = DAT_00b7a980,
     (bool)(bVar1 >> 6 & 1) || (bool)(bVar1 >> 7) != NAN(fVar7))) {
    fVar6 = (fVar7 - 5.0) / 25.0;
    fVar6 = DAT_00b7a974 - (3.0 - (fVar6 + fVar6)) * fVar6 * fVar6 * DAT_00b7a97c;
  }
  iVar3 = *(int *)(*(int *)(param_4 + 8) + 0x80);
  uVar9 = VectorFloatToUnsigned(fVar8 * fVar6,3);
  if (*(char *)(*(int *)(param_4 + 8) + 0x6c) == '\0') {
    if (iVar3 == 0x10) {
      *(undefined4 *)(param_4 + 0x40) = uVar9;
    }
    if (iVar3 != 0x10) {
      *(undefined4 *)(param_4 + 0x28) = uVar9;
    }
  }
  else {
    fVar8 = (float)VectorUnsignedToFloat(uVar9,(byte)(uVar5 >> 0x15) & 3);
    bVar4 = iVar3 == 0x10;
    fVar8 = fVar8 / DAT_00b7a974;
    if (bVar4) {
      *(float *)(param_4 + 0x80) = param_3 * 0.5;
    }
    if (!bVar4) {
      *(float *)(param_4 + 0x60) = param_3 * 0.5;
    }
    fVar6 = fVar8 + fVar2;
    fVar8 = fVar8 - fVar2;
    if (bVar4) {
      *(float *)(param_4 + 0x78) = fVar6;
    }
    if (bVar4) {
      *(float *)(param_4 + 0x7c) = fVar8;
    }
    if (!bVar4) {
      *(float *)(param_4 + 0x58) = fVar6;
    }
    if (!bVar4) {
      *(float *)(param_4 + 0x5c) = fVar8;
    }
  }
  *(float *)(*(int *)(param_4 + 4) + 4) = param_3;
  FUN_00b7a084();
  iVar3 = *(int *)(param_4 + 4);
  if ((*(char *)(iVar3 + 0xc4) == '\0') && (*(char *)(iVar3 + 0x5c) == '\x02')) {
    FUN_00b6a084(*(undefined4 *)(iVar3 + 0xa4),*(undefined4 *)(iVar3 + 0xa8),
                 *(undefined4 *)(iVar3 + 0xac),*(undefined4 *)(iVar3 + 0xb0),
                 *(undefined4 *)(iVar3 + 0xb4),*(undefined4 *)(iVar3 + 0xb8),
                 *(undefined4 *)(iVar3 + 0xbc),*(undefined4 *)(iVar3 + 0xc0),iVar3);
    *(undefined1 *)(iVar3 + 0xc4) = 1;
    return;
  }
  return;
}

